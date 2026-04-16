import SwiftUI
import Combine

// MARK: - BookingViewModel
// Handles the full booking flow:
//   1. Check wallet balance from Firestore
//   2. On confirm: deduct wallet → write Session → write MatchRequest → write Transaction → send Notification

@MainActor
class BookingViewModel: ObservableObject {
    let instructor: MatchProfile

    @Published var isOnline: Bool = true
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: String = "09:00 AM"
    @Published var selectedDuration: Int = 60
    @Published var topicsAndGoals: String = ""

    // Payment State
    @Published var showPaymentSheet: Bool = false
    @Published var showInsufficientFunds: Bool = false
    @Published var showSuccess: Bool = false
    @Published var showRequestSent: Bool = false
    @Published var isBooking: Bool = false

    let platformFee: Int = 12

    var sessionPrice: Int { (instructor.hourlyRate * selectedDuration) / 60 }
    var totalPrice: Int   { sessionPrice + platformFee }

    @Published var userBalance: Int = 0

    init(instructor: MatchProfile) {
        self.instructor = instructor
        Task { await loadBalance() }
    }

    // MARK: - Load Balance

    func loadBalance() async {
        if let user = await FirebaseDataService.shared.fetchCurrentUser() {
            self.userBalance = user.walletBalance
        }
    }

    // MARK: - Initiate Booking

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

    func confirmBooking() {
        guard !isBooking else { return }
        isBooking = true

        Task {
            defer { isBooking = false }
            let fds = FirebaseDataService.shared
            
            guard let user = await fds.fetchCurrentUser(),
                  let currentUid = user.id else { return }

            if instructor.status == .active {
                // ─── Paid Booking ───────────────────
                let newBalance = user.walletBalance - totalPrice

                // 1. Deduct wallet in Firestore
                await fds.updateWalletBalance(newBalance)
                self.userBalance = newBalance

                // 2. Build & create the Session document
                let sessionDate = buildSessionDate(day: selectedDate, timeString: selectedTime)
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let session = Session(
                    title: "\(instructor.role) Session",
                    instructorName: instructor.fullName,
                    instructorRole: instructor.role,
                    date: formatter.string(from: sessionDate),
                    time: selectedTime,
                    duration: "\(selectedDuration) min",
                    location: isOnline ? nil : instructor.location,
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
                    try await fds.createSession(session)
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
                await fds.createTransaction(tx)

                // 4. Write MatchRequest document (status: accepted for direct bookings)
                let match = MatchRequest(
                    fromUserId: currentUid,
                    toUserId: instructor.id,
                    fromUserName: user.fullName,
                    toUserName: instructor.fullName,
                    skillOffered: user.skillsToTeach.first ?? "Skills",
                    skillWanted: instructor.skillsToTeach.first ?? "Skills",
                    status: .accepted
                )
                try? await fds.createMatch(match)

                // 5. Write in-app notification
                await fds.createNotification(AppNotification(
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
                    message: topicsAndGoals
                )
                try? await fds.createMatch(match)

                // Write in-app notification
                await fds.createNotification(AppNotification(
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
