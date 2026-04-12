import SwiftUI

struct EventsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = "Events"
    @State private var selectedFilter = "All"
    let filters = ["All", "Free", "Paid", "Online", "Nearby"]
    
    var isNavigatedFromCourses: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !isNavigatedFromCourses {
                // Header if not included by parent
                AppHeader(
                    title: "Events",
                    backAction: { dismiss() },
                    actionIcon: "magnifyingglass",
                    action: { /* Search */ }
                )
                
                // Courses/Events Selector (Redundant if called from CoursesView but kept for standalone)
                HStack(spacing: 0) {
                    Button(action: { selectedTab = "Courses" }) {
                        Text("Courses")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .foregroundColor(.gray)
                    }
                    .accessibilityAddTraits(selectedTab == "Courses" ? .isSelected : [])
                    
                    Button(action: { selectedTab = "Events" }) {
                        Text("Events")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .foregroundColor(AppTheme.Colors.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.Colors.primary, lineWidth: 1)
                            )
                    }
                    .accessibilityAddTraits(selectedTab == "Events" ? .isSelected : [])
                }
                .padding(4)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Selection filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                Button(action: { selectedFilter = filter }) {
                                    Text(filter)
                                        .font(.system(size: 14, weight: .medium))
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
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Happening Soon")
                            .font(AppTheme.Typography.title3)
                            .padding(.horizontal)
                        
                        EventHeroCard(event: MockDataProvider.shared.happeningSoonEvent)
                            .padding(.horizontal)
                    }
                    
                    // Upcoming
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Upcoming")
                            .font(AppTheme.Typography.title3)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            ForEach(MockDataProvider.shared.upcomingEvents) { event in
                                UpcomingEventRow(event: event)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer().frame(height: 100)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Subcomponents

struct EventHeroCard: View {
    let event: Event
    
    @State private var isJoining = false
    @State private var hasJoined = false
    @State private var showsAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "desktopcomputer") // Placeholder for 1D image
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.3))
                            .accessibilityHidden(true)
                    )
                
                if event.isFree {
                    Text("FREE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(4)
                        .padding(16)
                }
            }
            
            Text(event.title)
                .font(.system(size: 22, weight: .bold))
            
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
                            let granted = await CalendarService.shared.requestAccess()
                            if !granted {
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
                            .font(.system(size: 14, weight: .bold))
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

struct UpcomingEventRow: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(width: 70, height: 70)
                .overlay(Image(systemName: "calendar").foregroundColor(.gray))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 16, weight: .bold))
                HStack {
                    Text("\(event.date) • \(event.time)")
                    Spacer()
                }
                .font(.caption)
                .foregroundColor(AppTheme.Colors.primary)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                    Text(event.location)
                }
                .font(.caption2)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .accessibilityElement(children: .combine)
    }
}
