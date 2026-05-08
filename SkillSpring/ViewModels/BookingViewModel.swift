import SwiftUI
import Combine
import FirebaseFirestore

/// Coordinates the booking flow for a tutor session.
///
/// Handles pricing, balance checks, payment decisions, session creation,
/// match request lifecycle, notifications, and local persistence.
@MainActor
class BookingViewModel: ObservableObject {
    let instructor: MatchProfile

    @Published var isOnline: Bool = true
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: String = "09:00 AM"
    @Published var selectedDuration: Int = 60
    @Published var topicsAndGoals: String = ""
    @Published var selectedVenueName: String = ""

    /// Uses the chosen venue when booking an in-person session.
    var bookingLocation: String? {
        guard !isOnline else { return nil }
        if !selectedVenueName.isEmpty { return selectedVenueName }
        return instructor.location.isEmpty ? nil : instructor.location
    }

    // Payment State
    @Published var showPaymentSheet: Bool = false
    @Published var showInsufficientFunds: Bool = false
    @Published var showSuccess: Bool = false
    @Published var showRequestSent: Bool = false
    @Published var isBooking: Bool = false

    let platformFee: Int = 12

    /// The session price before platform fees.
    var sessionPrice: Int { (instructor.hourlyRate * selectedDuration) / 60 }
    /// Total amount charged to the user including platform fee.
    var totalPrice: Int   { sessionPrice + platformFee }

    @Published var userBalance: Int = 0

    private let dataService: DataService

    init(instructor: MatchProfile, dataService: DataService? = nil) {
        self.instructor = instructor
        self.dataService = dataService ?? FirebaseDataService.shared
        Task { await loadBalance() }
    }

    // MARK: - Load Balance

    /// Loads the current user's wallet balance from Firestore.
    func loadBalance() async {
        if let user = await dataService.fetchCurrentUser() {
            self.userBalance = user.walletBalance
        }
    }

    // MARK: - Initiate Booking

    /// Decides whether to show payment flow or send a free request.
    /// Paid bookings require enough balance; free requests go straight to pending status.
    func initiateBooking() {
        if instructor.status == .active {
            if userBalance >= totalPrice {
                showPaymentSheet = true
            } else {
                showInsufficientFunds = true
            }
        } else {
            confirmBooking()
        }
    }

    // MARK: - Confirm Booking (writes to Firestore)

    /// Creates the session, transaction, match request, conversation, and notifications.
    /// Handles both paid and free booking workflows depending on instructor status.
    func confirmBooking() {
        guard !isBooking else { return }
        isBooking = true

        Task {
            defer { isBooking = false }
            
            guard let user = await dataService.fetchCurrentUser(),
                  let currentUid = user.id else { return }

            if instructor.status == .active {
                // ─── Paid Booking (Atomic) ───────────────────────────────
                // Use a Firestore transaction to atomically read-and-deduct
                // the wallet balance, preventing race conditions when booking
                // simultaneously from multiple devices.
                guard let uid = user.id else { return }
                let userRef = FirebaseDataService.shared.db.collection("users").document(uid)

                let newBalance: Int
                do {
                    newBalance = try await FirebaseDataService.shared.db.runTransaction { transaction, errorPointer in
                        let snapshot: DocumentSnapshot
                        do {
                            snapshot = try transaction.getDocument(userRef)
                        } catch let fetchError as NSError {
                            errorPointer?.pointee = fetchError
                            return nil
                        }
                        let liveBalance = snapshot.data()?["walletBalance"] as? Int ?? 0
                        guard liveBalance >= self.totalPrice else {
                            let insuf = NSError(domain: "Wallet", code: 402,
                                userInfo: [NSLocalizedDescriptionKey: "Insufficient funds"])
                            errorPointer?.pointee = insuf
                            return nil
                        }
                        let updated = liveBalance - self.totalPrice
                        transaction.updateData(["walletBalance": updated], forDocument: userRef)
                        return updated
                    } as! Int
                } catch {
                    print("[Booking] ❌ Atomic wallet transaction failed: \(error.localizedDescription)")
                    return
                }
                self.userBalance = newBalance

                // 2. Build & create the Session document
                let sessionDate = buildSessionDate(day: selectedDate, timeString: selectedTime)
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let session = Session(
                    title: "\(instructor.role) Session",
                    instructorName: instructor.fullName,
                    instructorRole: instructor.role,
                    instructorId: instructor.id,  // Added instructor ID for reviews
                    date: formatter.string(from: sessionDate),
                    time: selectedTime,
                    duration: "\(selectedDuration) min",
                    location: bookingLocation,
                    distance: nil,
                    timeRemaining: "Upcoming",
                    status: .upcoming,
                    type: isOnline ? .online : .inPerson,
                    category: instructor.skillsToTeach.first ?? "Session",
                    rating: nil,
                    notes: topicsAndGoals.isEmpty ? nil : topicsAndGoals,
                    matchPercentage: instructor.matchPercentage,
                    scheduledAt: sessionDate
                )
                do {
                    try await dataService.createSession(session)
                    // Write-through: cache session locally for offline access
                    PersistenceService.shared.saveSession(session)
                } catch {
                    print("[Booking] createSession error: \(error)")
                }

                // 3. Write transaction log
                let tx = CreditTransaction(
                    amount: -totalPrice,
                    type: .sessionPayment,
                    description: "Paid for \(instructor.fullName) session",
                    balanceAfter: newBalance,
                    referenceId: session.id
                )
                await dataService.createTransaction(tx)

                // 4. Write MatchRequest document (status: accepted for direct bookings)
                let match = MatchRequest(
                    fromUserId: currentUid,
                    toUserId: instructor.id,
                    fromUserName: user.fullName,
                    toUserName: instructor.fullName,
                    skillOffered: user.skillsToTeach.first ?? "Skills",
                    skillWanted: instructor.skillsToTeach.first ?? "Skills",
                    status: .accepted,
                    scheduledDate: selectedDate,
                    scheduledTime: selectedTime,
                    durationMinutes: selectedDuration,
                    isOnline: isOnline
                )
                try? await dataService.createMatch(match)

                // 4b. Create conversation so the instructor appears in the Messages tab
                let instructorUser = User(
                    id: instructor.id,
                    fullName: instructor.fullName,
                    phoneNumber: "",
                    skillsToTeach: instructor.skillsToTeach,
                    skillsToLearn: instructor.skillsToLearn,
                    location: instructor.location,
                    bio: instructor.bio,
                    profileImageURL: instructor.imageUrl
                )
                let conversation = Conversation(
                    participant: instructorUser,
                    lastMessage: "Session booked for \(formatter.string(from: sessionDate))",
                    lastMessageTime: "Just now",
                    unreadCount: 0,
                    messages: []
                )
                await dataService.createConversation(conversation, currentUserId: currentUid)

                // 5. Write in-app notification
                await dataService.createNotification(AppNotification(
                    type: .sessionConfirmed,
                    title: "Session Booked! ✅",
                    body: "Your session with \(instructor.fullName) on \(formatter.string(from: sessionDate)) is confirmed.",
                    referenceId: session.id
                ))

                // 6. Schedule local notifications
                NotificationManager.shared.scheduleBookingConfirmation(
                    sessionTitle: session.title,
                    instructorName: instructor.fullName,
                    time: selectedTime
                )
                NotificationManager.shared.scheduleSessionReminder(
                    identifier: session.id,
                    sessionTitle: session.title,
                    instructorName: instructor.fullName,
                    sessionDate: sessionDate
                )

                showSuccess = true

            } else {
                // ─── Free Request Flow ───────────────

                // Write MatchRequest (pending)
                let match = MatchRequest(
                    fromUserId: currentUid,
                    toUserId: instructor.id,
                    fromUserName: user.fullName,
                    toUserName: instructor.fullName,
                    skillOffered: user.skillsToTeach.first ?? "Skills",
                    skillWanted: instructor.skillsToTeach.first ?? "Skills",
                    status: .pending,
                    message: topicsAndGoals,
                    scheduledDate: selectedDate,
                    scheduledTime: selectedTime,
                    durationMinutes: selectedDuration,
                    isOnline: isOnline
                )
                try? await dataService.createMatch(match)

                // Create a pending session record so the booking shows in My Sessions
                let sessionDate = buildSessionDate(day: selectedDate, timeString: selectedTime)
                let session = Session(
                    title: "\(instructor.role) Session",
                    instructorName: instructor.fullName,
                    instructorRole: instructor.role,
                    date: DateFormatter.localizedString(from: sessionDate, dateStyle: .medium, timeStyle: .none),
                    time: selectedTime,
                    duration: "\(selectedDuration) min",
                    location: bookingLocation,
                    distance: nil,
                    timeRemaining: "Upcoming",
                    status: .upcoming,
                    type: isOnline ? .online : .inPerson,
                    category: instructor.skillsToTeach.first ?? "Session",
                    rating: nil,
                    notes: topicsAndGoals.isEmpty ? nil : topicsAndGoals,
                    matchPercentage: instructor.matchPercentage,
                    scheduledAt: sessionDate
                )
                do {
                    try await dataService.createSession(session)
                    PersistenceService.shared.saveSession(session)
                } catch {
                    print("[Booking] free-request createSession error: \(error)")
                }

                // Write in-app notification
                await dataService.createNotification(AppNotification(
                    type: .matchRequest,
                    title: "Request Sent 📩",
                    body: "Your skill-swap request to \(instructor.fullName) has been sent.",
                    referenceId: match.id
                ))

                NotificationManager.shared.scheduleBookingRequestSent(
                    instructorName: instructor.fullName
                )
                showRequestSent = true
            }

            HapticManager.success()
        }
    }

    // MARK: - Helpers

    /// Combines the selected day and time string into a concrete Date.
    /// Falls back to 10:00 AM if the time string cannot be parsed.
    func buildSessionDate(day: Date, timeString: String) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: day)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        if let parsed = formatter.date(from: timeString) {
            let timeParts = Calendar.current.dateComponents([.hour, .minute], from: parsed)
            components.hour = timeParts.hour
            components.minute = timeParts.minute
        } else {
            components.hour = 10; components.minute = 0
        }
        return Calendar.current.date(from: components) ?? day
    }

    var availableDates: [Date] {
        (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0,
                                  to: Calendar.current.startOfDay(for: Date()))
        }
    }

    var dateStripHeader: String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"
        return f.string(from: selectedDate)
    }
}
