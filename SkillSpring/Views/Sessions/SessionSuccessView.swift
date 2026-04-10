import SwiftUI

struct SessionSuccessView: View {
    @ObservedObject var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var calendarSuccess = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Icon
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.primary)
            }
            
            VStack(spacing: 12) {
                Text("Session Confirmed!")
                    .font(.system(size: 28, weight: .bold))
                Text("Your mentorship session with \(viewModel.instructor.fullName) has been successfully scheduled and added to your learning path.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Summary Card
            VStack(spacing: 16) {
                Image(viewModel.instructor.imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                
                VStack(spacing: 4) {
                    Text(viewModel.instructor.skillsToTeach.first ?? "Expert Session")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                    Text(viewModel.instructor.fullName)
                        .font(.system(size: 18, weight: .bold))
                    Text("Tue, Oct \(viewModel.selectedDate)")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(viewModel.selectedTime) - 11:30 AM")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "video.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                    Text("MEETING LINK")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("google.com/asdf-ghjk")
                        .font(.system(size: 10, weight: .bold))
                    Button(action: { }) {
                        Text("Copy")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Text("STATUS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("BOOKED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(4)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 32)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 10)
            .padding(.horizontal)
            
            Spacer()
            
            // Actions
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        let success = await CalendarManager.shared.addEvent(
                            title: "SkillSpryng Session with \(viewModel.instructor.fullName)",
                            startDate: Date(), // Simplified for demo
                            endDate: Date().addingTimeInterval(Double(viewModel.selectedDuration * 60))
                        )
                        calendarSuccess = success.0
                    }
                }) {
                    Label(calendarSuccess ? "Added to Calendar" : "Add to Calendar", systemImage: "calendar.badge.plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(calendarSuccess ? .gray : AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).stroke(calendarSuccess ? Color.gray : AppTheme.Colors.primary, lineWidth: 2))
                }
                
                Button(action: { }) {
                    Label("Set Reminder", systemImage: "bell.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                Button(action: { dismiss() }) {
                    Text("Go to Home")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}
