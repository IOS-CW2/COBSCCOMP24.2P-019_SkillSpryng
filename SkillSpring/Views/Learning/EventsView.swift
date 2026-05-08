import SwiftUI

/// Displays upcoming learning events and workshops.
///
/// Includes filters for free/paid, online/nearby, and highlights the next
/// happening event with a hero card.
@MainActor
struct EventsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = "Events"
    @State private var selectedFilter = "All"
    @State private var selectedEvent: Event? = nil
    let filters = ["All", "Free", "Paid", "Online", "Nearby"]
    @ObservedObject var vm: LearningViewModel = LearningViewModel()

    var isNavigatedFromCourses: Bool = false

    init(isNavigatedFromCourses: Bool = false) {
        self.isNavigatedFromCourses = isNavigatedFromCourses
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !isNavigatedFromCourses {
                // Standalone header for Events when this view is not embedded inside CoursesView.
                AppHeader(
                    title: "Events",
                    backAction: { dismiss() },
                    actionIcon: "magnifyingglass",
                    action: { /* Search */ }
                )
                
                // Courses/Events Selector (Redundant if called from CoursesView but kept for standalone)
                HStack(spacing: 8) {
                    Button(action: { dismiss() }) {
                        Text("Courses")
                            .font(AppTheme.Typography.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == "Courses" ? AppTheme.Colors.primary : Color.clear)
                            .foregroundColor(selectedTab == "Courses" ? .white : .gray)
                            .clipShape(Capsule())
                    }
                    .accessibilityAddTraits(selectedTab == "Courses" ? .isSelected : [])
                    
                    Button(action: { selectedTab = "Events" }) {
                        Text("Events")
                            .font(AppTheme.Typography.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == "Events" ? AppTheme.Colors.primary : Color.clear)
                            .foregroundColor(selectedTab == "Events" ? .white : .gray)
                            .clipShape(Capsule())
                    }
                    .accessibilityAddTraits(selectedTab == "Events" ? .isSelected : [])
                }
                .padding(6)
                .background(Color(.systemGray6))
                .cornerRadius(28)
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Selection filters
                // These chips let users narrow events by type and location.
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                Button(action: { selectedFilter = filter }) {
                                    Text(filter)
                                        .font(AppTheme.Typography.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedFilter == filter ? AppTheme.Colors.primary : Color(.systemGray6))
                                        .foregroundColor(selectedFilter == filter ? .white : .gray)
                                        .cornerRadius(20)
                                }
                                .accessibilityAddTraits(selectedFilter == filter ? .isSelected : [])
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Happening Soon
                    // Promotes the next available live event front and center.
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Happening Soon")
                            .font(AppTheme.Typography.title3)
                            .padding(.horizontal)
                        
                        if let event = vm.happeningSoonEvent {
                            EventHeroCard(event: event)
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedEvent = event
                                }
                        }
                    }
                    
                    // Upcoming
                    // Lists all upcoming events after the hero highlight.
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Upcoming")
                            .font(AppTheme.Typography.title3)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            ForEach(vm.upcomingEvents) { event in
                                Button(action: { selectedEvent = event }) {
                                    UpcomingEventRow(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .accessibilityHint("Tap to view details for \(event.title).")
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer().frame(height: 100)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedEvent) { event in
            EventDetailSheet(event: event)
        }
    }
}

// MARK: - Event Detail Sheet

struct EventDetailSheet: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Image(event.imageUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.12), radius: 15, x: 0, y: 10)

                    VStack(alignment: .leading, spacing: 14) {
                        Text(event.title)
                            .font(AppTheme.Typography.largeTitle)
                            .lineLimit(3)
                        Text("Hosted by \(event.instructor)")
                            .font(AppTheme.Typography.title3)
                            .foregroundColor(.gray)

                        HStack(spacing: 12) {
                            Text(event.date)
                                .font(AppTheme.Typography.subheadline)
                            Text(event.time)
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.primary)
                        }

                        Text(event.location)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)

                        Text("Tap below to join this event and receive a local notification when your spot is requested.")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 14) {
                        Button(action: {
                            NotificationManager.shared.scheduleBookingRequestSent(instructorName: event.instructor)
                            dismiss()
                        }) {
                            Text("Request Spot")
                                .font(AppTheme.Typography.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.primary)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }

                        Button(action: { dismiss() }) {
                            Text("Close")
                                .font(AppTheme.Typography.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                .padding(.bottom, 32)
            }
            .navigationTitle("Event Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Subcomponents

/// The feature card for a single upcoming event.
/// Includes attendance info and a calendar join flow.
struct EventHeroCard: View {
    let event: Event
    
    @State private var isJoining = false
    @State private var hasJoined = false
    @State private var showsAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Image(event.imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(20)
                
                if event.isFree {
                    Text("FREE")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(4)
                        .padding(16)
                }
            }
            
            Text(event.title)
                .font(AppTheme.Typography.title2)
            
            HStack {
                // Instructor
                HStack {
                    Circle().fill(.gray).frame(width: 32, height: 32)
                    Text(event.instructor)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Attendance
                HStack {
                    Image(systemName: "person.2.fill")
                    Text("\(event.attendanceCount) attending")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            
            HStack {
                if let spots = event.spotsLeft {
                    Text("\(spots) spots left")
                        .font(.caption)
                        .foregroundColor(.red)
                        .bold()
                }
                
                Spacer()
                
                Button(action: {
                    guard !hasJoined else { return }
                    isJoining = true
                    
                    Task {
                        // Request Permission
                        if !CalendarService.shared.checkCalendarAccess() {
                            await CalendarService.shared.requestAccess()
                            if CalendarService.shared.calendarDenied {
                                await MainActor.run {
                                    alertMessage = "SkillSpryng needs calendar access to add community events. Please enable it in Settings."
                                    showsAlert = true
                                    isJoining = false
                                }
                                return
                            }
                        }
                        
                        let startDate = buildEventDate()
                        // Default community events to 1 hour
                        let endDate = startDate.addingTimeInterval(3600)
                        
                        let notes = """
                        🏆 Community Event: \(event.title)
                        Host: \(event.instructor)
                        Category: \(event.category)
                        
                        Remember to arrive 15 minutes early!
                        """
                        
                        let eventId = await CalendarService.shared.addEventToCalendar(
                            title: "Workshop: \(event.title)",
                            startDate: startDate,
                            endDate: endDate,
                            location: event.location,
                            notes: notes
                        )
                        
                        await MainActor.run {
                            isJoining = false
                            if eventId != nil {
                                hasJoined = true
                                NotificationManager.shared.scheduleBookingConfirmation(
                                    sessionTitle: event.title,
                                    instructorName: event.instructor,
                                    time: event.time
                                )
                                HapticManager.success()
                            } else {
                                alertMessage = "Failed to add workshop to your calendar."
                                showsAlert = true
                                HapticManager.error()
                            }
                        }
                    }
                }) {
                    HStack {
                        if isJoining {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else if hasJoined {
                            Image(systemName: "checkmark")
                        }
                        Text(hasJoined ? "Joined" : "Join Event")
                            .font(AppTheme.Typography.subheadline)
                    }
                    .foregroundColor(hasJoined ? AppTheme.Colors.primary : .white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(hasJoined ? Color.clear : AppTheme.Colors.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(hasJoined ? AppTheme.Colors.primary : Color.clear, lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
                .disabled(hasJoined || isJoining)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .alert("Calendar", isPresented: $showsAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func buildEventDate() -> Date {
        // e.g. event.date = "Oct 24", event.time = "10:00 AM"
        var components = DateComponents()
        components.year = Calendar.current.component(.year, from: Date())
        
        let parts = event.date.components(separatedBy: .whitespaces)
        if parts.count >= 2, let day = Int(parts[1]) {
            components.month = 10 // Mock fixed to Oct
            components.day = day
        } else {
            components.month = 10
            components.day = 25
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        if let parsed = formatter.date(from: event.time) {
            let timeParts = Calendar.current.dateComponents([.hour, .minute], from: parsed)
            components.hour = timeParts.hour
            components.minute = timeParts.minute
        } else {
            components.hour = 10
        }
        
        return Calendar.current.date(from: components) ?? Date().addingTimeInterval(86400)
    }
}

/// Compact row for an individual upcoming event.
/// Shows the event title, timing, and location details.
struct UpcomingEventRow: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 16) {
            Image(event.imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(18)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(AppTheme.Typography.headline)
                    .lineLimit(2)
                
                Text("\(event.date) • \(event.time)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.primary)
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                    Text(event.location)
                }
                .font(AppTheme.Typography.caption2)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(24)
        .accessibilityElement(children: .combine)
    }
}
