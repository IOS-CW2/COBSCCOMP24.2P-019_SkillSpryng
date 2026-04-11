import SwiftUI
import Combine

@MainActor
class BookingViewModel: ObservableObject {
    let instructor: MatchProfile
    
    @Published var isOnline: Bool = true
    @Published var selectedDate: Int = 25
    @Published var selectedTime: String = "10:00 AM"
    @Published var selectedDuration: Int = 60
    @Published var topicsAndGoals: String = ""
    
    // Payment Logic
    @Published var showPaymentSheet: Bool = false
    @Published var showInsufficientFunds: Bool = false
    @Published var showSuccess: Bool = false
    @Published var showRequestSent: Bool = false
    
    let platformFee: Int = 12
    
    var sessionPrice: Int {
        let baseRate = instructor.hourlyRate
        return (baseRate * selectedDuration) / 60
    }
    
    var totalPrice: Int {
        return sessionPrice + platformFee
    }
    
    var userBalance: Int {
        return MockDataProvider.shared.currentUser.walletBalance
    }
    
    init(instructor: MatchProfile) {
        self.instructor = instructor
    }
    
    func initiateBooking() {
        if instructor.status == .active {
            // Paid flow
            if userBalance >= totalPrice {
                showPaymentSheet = true
            } else {
                showInsufficientFunds = true
            }
        } else {
            // Request flow
            confirmBooking()
        }
    }
    
    func confirmBooking() {
        let notificationManager = NotificationManager.shared
        
        if instructor.status == .active {
            // Paid booking confirmed
            MockDataProvider.shared.currentUser.walletBalance -= totalPrice
            showSuccess = true
            
            // 1. Immediate booking confirmation notification
            notificationManager.scheduleBookingConfirmation(
                sessionTitle: "\(instructor.role) Session",
                instructorName: instructor.fullName,
                time: selectedTime
            )
            
            // 2. Reminder 30 min before the session
            // Build a representative date for Oct selectedDate at selectedTime
            let sessionDate = buildSessionDate(day: selectedDate, timeString: selectedTime)
            notificationManager.scheduleSessionReminder(
                identifier: "\(instructor.id)-\(selectedDate)-\(selectedTime)",
                sessionTitle: "\(instructor.role) Session",
                instructorName: instructor.fullName,
                sessionDate: sessionDate
            )
            
        } else {
            // Free request flow
            showRequestSent = true
            
            // Notify that the request has been sent
            notificationManager.scheduleBookingRequestSent(instructorName: instructor.fullName)
        }
    }
    
    // MARK: - Helpers
    
    /// Builds a Date for the selected day + time string (e.g. "10:00 AM") in October of the current year.
    private func buildSessionDate(day: Int, timeString: String) -> Date {
        var components = DateComponents()
        components.year   = Calendar.current.component(.year, from: Date())
        components.month  = 10 // October (hardcoded to match UI)
        components.day    = day
        
        // Parse time string like "10:00 AM" or "2:30 PM"
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        if let parsed = formatter.date(from: timeString) {
            let timeParts = Calendar.current.dateComponents([.hour, .minute], from: parsed)
            components.hour   = timeParts.hour
            components.minute = timeParts.minute
        } else {
            components.hour   = 10
            components.minute = 0
        }
        
        return Calendar.current.date(from: components) ?? Date().addingTimeInterval(86400)
    }
}

