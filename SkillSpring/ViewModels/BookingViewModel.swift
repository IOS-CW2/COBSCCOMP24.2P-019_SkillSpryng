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
        // Mock logic: deduct points if paid
        if instructor.status == .active {
            MockDataProvider.shared.currentUser.walletBalance -= totalPrice
            showSuccess = true
        } else {
            showRequestSent = true
        }
    }
}
