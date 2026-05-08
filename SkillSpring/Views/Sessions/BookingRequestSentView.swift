import SwiftUI

// MARK: - BookingRequestSentView
// Confirmation screen displayed after a booking request is sent.
// Shows the session summary, instructor details, and calendar integration.
struct BookingRequestSentView: View {
    let instructor: MatchProfile
    let sessionDate: Date   // Real date object
    let time: String
    let isOnline: Bool
    let duration: Int       // minutes
    let venueName: String?
    @Environment(\.dismiss) private var dismiss
    
    // Calendar State
    @State private var calendarSuccess = false
    @State private var showCalendarToast = false
    @State private var showsAlert = false
    @State private var alertMessage = ""
    
    // Formatted date string for display
    // Converts the selected Date object into a friendly label.
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: sessionDate)
    }

    private var computedEndTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        guard let start = formatter.date(from: time) else { return time }
        let end = Calendar.current.date(byAdding: .minute, value: duration, to: start) ?? start
        return formatter.string(from: end)
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
            .accessibilityHidden(true)
            
            VStack(spacing: 12) {
                Text("Request Sent!")
                    .font(AppTheme.Typography.title)
                Text("Waiting for \(instructor.fullName) to accept your request.")
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .accessibilityElement(children: .combine)
            
            // Summary Card
            VStack(spacing: 20) {
                HStack {
                    Text("FORMAT")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(isOnline ? "Online • Jitsi Meet" : "In-Person • \(venueName ?? "Public Venue")")
                        .font(AppTheme.Typography.badge)
                }
                
                if isOnline {
                    HStack {
                        Text("MEETING LINK")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Jitsi Meet")
                            .font(AppTheme.Typography.badge)
                    }
                } else {
                    HStack {
                        Text("LOCATION")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(venueName ?? "Selected Venue")
                            .font(AppTheme.Typography.badge)
                    }
                }
                
                HStack {
                    Text("MENTOR")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                    Spacer()
                    HStack {
                        Image(instructor.imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                        Text(instructor.fullName)
                            .font(AppTheme.Typography.badge)
                    }
                }
                
                HStack {
                    Text("DATE")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(formattedDate)
                        .font(AppTheme.Typography.badge)
                }
                
                HStack {
                    Text("TIME")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(time) - \(computedEndTime)")
                        .font(AppTheme.Typography.badge)
                }
                
                HStack {
                    Text("DURATION")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(duration) min")
                        .font(AppTheme.Typography.badge)
                }
                
                HStack {
                    Text("COST")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("FREE (Request based)")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 10)
            .padding(.horizontal)
            .accessibilityElement(children: .combine)
            
            Text("Coach has 24 hours to respond. You'll be notified.")
                .font(AppTheme.Typography.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(spacing: 16) {
                // Calendar Add Button
                Button(action: {
                    guard !calendarSuccess else { return }
                    
                    Task {
                        if !CalendarService.shared.checkCalendarAccess() {
                            await CalendarService.shared.requestAccess()
                            if CalendarService.shared.calendarDenied {
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
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(calendarSuccess ? AppTheme.Colors.primary : .white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(calendarSuccess ? AppTheme.Colors.primary.opacity(0.1) : Color.black)
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
                        .font(AppTheme.Typography.headline)
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
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Added to Calendar!")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.white)
                        Text("Check \(formattedDate) in your Calendar app")
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.Colors.primary.gradient)
                )
                .padding(.horizontal)
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showCalendarToast)
            }
        }
    }
}
