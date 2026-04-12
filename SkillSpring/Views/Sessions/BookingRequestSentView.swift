import SwiftUI

struct BookingRequestSentView: View {
    let instructor: MatchProfile
    let sessionDate: Date   // Real date object
    let time: String
    @Environment(\.dismiss) private var dismiss
    
    // Calendar State
    @State private var calendarSuccess = false
    @State private var showCalendarToast = false
    @State private var showsAlert = false
    @State private var alertMessage = ""
    
    // Formatted date string for display
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: sessionDate)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 12) {
                Text("Request Sent!")
                    .font(.system(size: 28, weight: .bold))
                Text("Waiting for \(instructor.fullName) to accept your request.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Summary Card
            VStack(spacing: 20) {
                HStack {
                    Text("FORMAT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Online • Jitsi Meet")
                        .font(.system(size: 12, weight: .bold))
                }
                
                HStack {
                    Text("MENTOR")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    HStack {
                        Image(instructor.imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                        Text(instructor.fullName)
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                
                HStack {
                    Text("DATE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(formattedDate)
                        .font(.system(size: 12, weight: .bold))
                }
                
                HStack {
                    Text("TIME")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(time) - 11:30 AM")
                        .font(.system(size: 12, weight: .bold))
                }
                
                HStack {
                    Text("DURATION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("60 min")
                        .font(.system(size: 12, weight: .bold))
                }
                
                HStack {
                    Text("COST")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("FREE (Request based)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 10)
            .padding(.horizontal)
            
            Text("Coach has 24 hours to respond. You'll be notified.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(spacing: 16) {
                // Calendar Add Button
                Button(action: {
                    guard !calendarSuccess else { return }
                    
                    Task {
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
                        
                        // Parse real session date
                        var components = Calendar.current.dateComponents([.year, .month, .day], from: sessionDate)
                        let formatter = DateFormatter()
                        formatter.dateFormat = "h:mm a"
                        if let timeDate = formatter.date(from: time) {
                            let timeParts = Calendar.current.dateComponents([.hour, .minute], from: timeDate)
                            components.hour = timeParts.hour
                            components.minute = timeParts.minute
                        }
                        let startDate = Calendar.current.date(from: components) ?? Date()
                        
                        let identifier = await CalendarService.shared.addSessionToCalendar(
                            title: "Peer Session",
                            instructorName: instructor.fullName,
                            startDate: startDate,
                            durationMinutes: 60,
                            format: "ONLINE",
                            locationName: nil,
                            sessionId: UUID().uuidString
                        )
                        
                        await MainActor.run {
                            if identifier != nil {
                                calendarSuccess = true
                                showCalendarToast = true
                                HapticManager.success()
                                // Auto-hide toast after 3 seconds
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
                        .foregroundColor(calendarSuccess ? AppTheme.Colors.primary : .white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(calendarSuccess ? Color.green.opacity(0.1) : Color.black)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(calendarSuccess ? AppTheme.Colors.primary : Color.clear, lineWidth: 1)
                        )
                }
                .disabled(calendarSuccess)
                
                // Done Button
                Button(action: { dismiss() }) {
                    Text("Done")
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
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.gradient)
                )
                .padding(.horizontal)
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showCalendarToast)
            }
        }
    }
}
