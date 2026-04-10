import SwiftUI

struct MySessionsView: View {
    @State private var selectedFilter = "All"
    @Namespace private var animation
    let filters = ["All", "Upcoming", "Completed", "Cancelled"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Header
            AppHeader(title: "My Sessions", showBackButton: true)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Category Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                FilterChip(title: filter, isSelected: selectedFilter == filter) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if selectedFilter == "All" || selectedFilter == "Upcoming" {
                        UpcomingSessionsSection()
                    }
                    
                    if selectedFilter == "All" || selectedFilter == "Completed" || selectedFilter == "Cancelled" {
                        SessionHistorySection(filter: selectedFilter)
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.top)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Upcoming Section
struct UpcomingSessionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "TODAY")
                .padding(.horizontal)
            
            // Today's Large Card
            if let todaySession = MockDataProvider.shared.mockSessions.first(where: { $0.date == "Oct 24" && $0.type == .online }) {
                MainSessionCard(session: todaySession)
                    .padding(.horizontal)
            }
            
            SectionHeader(title: "TOMORROW")
                .padding(.horizontal)
                .padding(.top, 8)
            
            // Tomorrow's In-Person Card
            if let tomorrowSession = MockDataProvider.shared.mockSessions.first(where: { $0.date == "Oct 25" }) {
                MainSessionCard(session: tomorrowSession)
                    .padding(.horizontal)
            }
            
            // Next Week List
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "NEXT WEEK", actionTitle: "See All", action: { })
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    CompactSessionRow(date: "OCT 28", title: "UI Typography Workshop", time: "Virtual • 10:00 AM")
                    CompactSessionRow(date: "OCT 30", title: "Growth Mindset Group", time: "In-Person • 04:00 PM")
                }
                .padding(.horizontal)
            }
            
            // Bottom Action Cards
            HStack(spacing: 16) {
                ActionCard(title: "Prepare for your next session", subtitle: "Review 3 shared documents", icon: "sparkles", color: Color.blue.opacity(0.1))
                VStack(spacing: 16) {
                    ActionCard(title: "Notes", subtitle: "", icon: "note.text", color: Color.green.opacity(0.1))
                    ActionCard(title: "Progress Overview", subtitle: "", icon: "chart.bar.fill", color: Color.gray.opacity(0.1))
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - History Section
struct SessionHistorySection: View {
    let filter: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SectionHeader(title: "THIS MONTH")
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(MockDataProvider.shared.mockSessions.filter { 
                    $0.date != "Oct 24" && $0.date != "Oct 25" &&
                    (filter == "All" || $0.status.rawValue == filter.uppercased())
                }) { session in
                    HistorySessionRow(session: session)
                }
            }
            .padding(.horizontal)
            
            SectionHeader(title: "SEPTEMBER")
                .padding(.horizontal)
            
            if filter == "All" || filter == "Completed" {
                if let sepSession = MockDataProvider.shared.mockSessions.first(where: { $0.date.contains("Sep") }) {
                    HistorySessionRow(session: sepSession)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Subcomponents

struct MainSessionCard: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                StatusBadge(text: session.type.rawValue, color: .green)
                
                Spacer()
                
                if let remaining = session.timeRemaining {
                    Text(remaining)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(session.title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    Image("instructor1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(session.instructorName)
                            .font(.system(size: 12, weight: .bold))
                        Text(session.instructorRole)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            HStack(spacing: 12) {
                SkillBadge.info(session.date, icon: "calendar")
                SkillBadge.info(session.time, icon: "clock")
                SkillBadge.info(session.duration, icon: "timer")
            }
            
            if let location = session.location {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        SectionHeader(title: "Location")
                        Text(location)
                            .font(.system(size: 12, weight: .bold))
                    }
                    
                    Spacer()
                    
                    if let dist = session.distance {
                        StatusBadge(text: dist, color: AppTheme.Colors.primary)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                
                Label("Safety monitoring will activate at session time", systemImage: "checkmark.shield.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.green)
            }
            
            HStack(spacing: 12) {
                NavigationLink(destination: SessionDetailView(session: session)) {
                    Text("View Details")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.Colors.primary.opacity(0.2), lineWidth: 1))
                }
                
                if session.type == .online {
                    NavigationLink(destination: LiveSessionView(session: session)) {
                        Text("Join Session")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(12)
                    }
                } else {
                    Button(action: { }) {
                        Text("Get Location")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 10)
    }
}

struct CompactSessionRow: View {
    let date: String
    let title: String
    let time: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text(date.split(separator: " ").first ?? "")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                Text(date.split(separator: " ").last ?? "")
                    .font(.system(size: 18, weight: .bold))
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                Text(time)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}

struct HistorySessionRow: View {
    let session: Session
    
    var body: some View {
        NavigationLink(destination: SessionDetailView(session: session)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 14) {
                    Image("instructor1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(session.title)
                                .font(.system(size: 15, weight: .bold))
                            Spacer()
                            StatusBadge.sessionStatus(session.status)
                        }
                        
                        Text("with \(session.instructorName)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 8) {
                            Label(session.date, systemImage: "calendar")
                            Text("•")
                            Text(session.time)
                        }
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    StatusBadge(text: session.category, color: .gray)
                    
                    Spacer()
                    
                    if let rating = session.rating {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { i in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(i < rating ? .orange : Color(.systemGray5))
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.Colors.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(color)
        .cornerRadius(20)
    }
}
