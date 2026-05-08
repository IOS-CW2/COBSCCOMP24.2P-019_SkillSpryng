import SwiftUI

// MARK: - SessionSuccessView
// Confirmation screen shown after a session booking is successfully created.
// Includes calendar integration, link sharing, and reminder setup.
struct SessionSuccessView: View {
    @ObservedObject var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var calendarSuccess = false
    @State private var showCalendarToast = false
    @State private var showsAlert = false
    @State private var alertMessage = ""
    @State private var linkCopied = false
    @State private var reminderSet = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: viewModel.selectedDate)
    }

    private var sessionLocationLabel: String {
        viewModel.isOnline ? "MEETING LINK" : "LOCATION"
    }

    private var sessionLocationValue: String {
        if viewModel.isOnline {
            return "google.com/asdf-ghjk"
        }
        if !viewModel.selectedVenueName.isEmpty {
            return viewModel.selectedVenueName
        }
        return viewModel.instructor.location.isEmpty ? "Selected Venue" : viewModel.instructor.location
    }

    /// Calculates the session end time by adding selectedDuration minutes to
    /// the parsed selectedTime string. Replaces the previous hardcoded "11:30 AM".
    private var computedEndTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        guard let start = formatter.date(from: viewModel.selectedTime) else {
            return viewModel.selectedTime
        }
        let end = Calendar.current.date(
            byAdding: .minute,
            value: viewModel.selectedDuration,
            to: start
        ) ?? start
        return formatter.string(from: end)
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
            .accessibilityHidden(true)
            
            VStack(spacing: 12) {
                Text("Session Confirmed!")
                    .font(AppTheme.Typography.title)
                Text("Your mentorship session with \(viewModel.instructor.fullName) has been successfully scheduled and added to your learning path.")
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .accessibilityElement(children: .combine)
            
            // Summary Card
            VStack(spacing: 16) {
                Image(viewModel.instructor.imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                
                VStack(spacing: 4) {
                    Text(viewModel.instructor.skillsToTeach.first ?? "Expert Session")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(AppTheme.Colors.primary)
                    Text(viewModel.instructor.fullName)
                        .font(AppTheme.Typography.headline)
                    Text(formattedDate)
                        .font(AppTheme.Typography.subheadline)
                    Text("\(viewModel.selectedTime) – \(computedEndTime)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: viewModel.isOnline ? "video.fill" : "mappin.circle.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                    Text(sessionLocationLabel)
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(sessionLocationValue)
                        .font(AppTheme.Typography.badge)
                    if viewModel.isOnline {
                        Button(action: {
                            UIPasteboard.general.string = sessionLocationValue
                            withAnimation { linkCopied = true }
                        }) {
                            Text(linkCopied ? "Copied!" : "Copy")
                                .font(AppTheme.Typography.badge)
                                .foregroundColor(linkCopied ? .gray : AppTheme.Colors.primary)
                        }
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Text("STATUS")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("BOOKED")
                        .font(AppTheme.Typography.badge)
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
            .accessibilityElement(children: .combine)
            
            Spacer()
            
            // Actions
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        // 1. Check & Request Access
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
                        
                        // 2. Build dates
                        let startDate = viewModel.buildSessionDate(day: viewModel.selectedDate, timeString: viewModel.selectedTime)
                        
                        // 3. Add to Calendar
                        let identifier = await CalendarService.shared.addSessionToCalendar(
                            title: viewModel.topicsAndGoals.isEmpty ? "Expert Session" : viewModel.topicsAndGoals,
                            instructorName: viewModel.instructor.fullName,
                            startDate: startDate,
                            durationMinutes: viewModel.selectedDuration,
                            format: viewModel.isOnline ? "ONLINE" : "IN-PERSON",
                            locationName: viewModel.isOnline ? nil : sessionLocationValue,
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
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(calendarSuccess ? .gray : AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).stroke(calendarSuccess ? Color.gray : AppTheme.Colors.primary, lineWidth: 2))
                }
                .disabled(calendarSuccess)
                
                Button(action: {
                    guard !reminderSet else { return }
                    NotificationManager.shared.scheduleSessionReminder(
                        identifier: viewModel.instructor.id,
                        sessionTitle: "\(viewModel.instructor.role) Session",
                        instructorName: viewModel.instructor.fullName,
                        sessionDate: viewModel.selectedDate
                    )
                    withAnimation { reminderSet = true }
                }) {
                    Label(reminderSet ? "Reminder Set" : "Set Reminder", systemImage: reminderSet ? "bell.badge.fill" : "bell.fill")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(reminderSet ? .gray : AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .disabled(reminderSet)
                
                Button(action: { dismiss() }) {
                    Text("Go to Home")
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
                .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.Colors.primary.gradient))
                .padding(.horizontal)
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showCalendarToast)
            }
        }
    }
}
