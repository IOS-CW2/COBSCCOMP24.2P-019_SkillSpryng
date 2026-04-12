import SwiftUI

struct SessionSuccessView: View {
    @ObservedObject var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var calendarSuccess = false
    @State private var showCalendarToast = false
    @State private var showsAlert = false
    @State private var alertMessage = ""
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: viewModel.selectedDate)
    }
    
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
                    Text(formattedDate)
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
                        // 1. Check & Request Access
                        if !CalendarService.shared.checkCalendarAccess() {
                            let granted = await CalendarService.shared.requestAccess()
                            if !granted {
                                await MainActor.run {
                                    alertMessage = "SkillSpryng needs calendar access to add this event. Please enable it in Settings."
                                    showsAlert = true
                                }
                                return
                            }
                        }
                        
                        // 2. Build dates
                        let startDate = viewModel.buildSessionDate(day: viewModel.selectedDate, timeString: viewModel.selectedTime)
                        
                        // 3. Add to Calendar
                        let identifier = await CalendarService.shared.addSessionToCalendar(
                            title: viewModel.topicsAndGoals.isEmpty ? "Expert Session" : viewModel.topicsAndGoals,
                            instructorName: viewModel.instructor.fullName,
                            startDate: startDate,
                            durationMinutes: viewModel.selectedDuration,
                            format: viewModel.isOnline ? "ONLINE" : "IN-PERSON",
                            locationName: viewModel.isOnline ? nil : "Agreed Location",
                            latitude: viewModel.isOnline ? nil : 6.9271,
                            longitude: viewModel.isOnline ? nil : 79.8612,
                            sessionId: UUID().uuidString
                        )
                        
                        await MainActor.run {
                            if let id = identifier {
                                calendarSuccess = true
                                showCalendarToast = true
                                print("Saved to calendar with ID: \(id)")
                                HapticManager.success()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation { showCalendarToast = false }
                                }
                            } else {
                                alertMessage = "Failed to add to calendar."
                                showsAlert = true
                                HapticManager.error()
                            }
                        }
                    }
                }) {
                    Label(calendarSuccess ? "Added to Calendar" : "Add to Calendar", systemImage: calendarSuccess ? "calendar.badge.checkmark" : "calendar.badge.plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(calendarSuccess ? .gray : AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).stroke(calendarSuccess ? Color.gray : AppTheme.Colors.primary, lineWidth: 2))
                }
                .disabled(calendarSuccess)
                
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
        .alert("Calendar", isPresented: $showsAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .overlay(alignment: .top) {
            if showCalendarToast {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Added to Calendar!")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("Check \(formattedDate) in your Calendar app")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.green.gradient))
                .padding(.horizontal)
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showCalendarToast)
            }
        }
    }
}
