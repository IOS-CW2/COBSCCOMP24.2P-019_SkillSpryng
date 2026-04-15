import SwiftUI

struct MySessionsView: View {
    @StateObject private var vm = SessionsViewModel()
    @State private var selectedFilter = "All"
    @Namespace private var animation
    let filters = ["All", "Upcoming", "Completed", "Cancelled"]

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "My Sessions", showBackButton: true)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
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
                        UpcomingSessionsSection(vm: vm)
                    }

                    if selectedFilter == "All" || selectedFilter == "Completed" || selectedFilter == "Cancelled" {
                        let historySessions = vm.historySessions.filter {
                            selectedFilter == "All" || $0.status.rawValue == selectedFilter.uppercased()
                        }
                        if historySessions.isEmpty {
                            EmptySessionsView(filter: selectedFilter).padding(.top, 40)
                        } else {
                            SessionHistorySection(vm: vm, filter: selectedFilter)
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.top)
            }
        }
        .navigationBarHidden(true)
    }
}

struct UpcomingSessionsSection: View {
    @ObservedObject var vm: SessionsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "TODAY").padding(.horizontal)

            if let todaySession = vm.todaySession {
                MainSessionCard(session: todaySession).padding(.horizontal)
            } else {
                Text("No session today")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }

            SectionHeader(title: "TOMORROW").padding(.horizontal).padding(.top, 8)

            if let tomorrowSession = vm.tomorrowSession {
                MainSessionCard(session: tomorrowSession).padding(.horizontal)
            } else {
                Text("No session tomorrow")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "NEXT WEEK", actionTitle: "See All", action: { }).padding(.horizontal)
                VStack(spacing: 12) {
                    ForEach(vm.upcomingSessions.prefix(3)) { session in
                        NavigationLink(destination: SessionDetailView(session: session)) {
                            CompactSessionRow(date: session.date, title: session.title, time: session.time)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }

            HStack(spacing: 16) {
                ActionCard(title: "Prepare for your next session", subtitle: "Review 3 shared documents", icon: "sparkles", color: Color.blue.opacity(0.1))
                VStack(spacing: 16) {
                    ActionCard(title: "Notes", subtitle: "", icon: "note.text", color: Color.green.opacity(0.1))
                    NavigationLink(destination: LearningAnalyticsView()) {
                        ActionCard(title: "Progress Overview", subtitle: "", icon: "chart.bar.fill", color: Color.gray.opacity(0.1))
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - History Section
struct SessionHistorySection: View {
    @ObservedObject var vm: SessionsViewModel
    let filter: String

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SectionHeader(title: "THIS MONTH").padding(.horizontal)

            VStack(spacing: 16) {
                ForEach(vm.historySessions.filter {
                    filter == "All" || $0.status.rawValue == filter.uppercased()
                }) { session in
                    HistorySessionRow(session: session)
                }
            }
            .padding(.horizontal)
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
                        .font(AppTheme.Typography.badge)
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
                            .font(AppTheme.Typography.badge)
                        Text(session.instructorRole)
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .accessibilityElement(children: .combine)
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
                            .font(AppTheme.Typography.badge)
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
                    .accessibilityHidden(true)
            }
            
            HStack(spacing: 12) {
                NavigationLink(destination: SessionDetailView(session: session)) {
                    Text("View Details")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.Colors.primary.opacity(0.2), lineWidth: 1))
                }
                
                if session.type == .online {
                    NavigationLink(destination: LiveSessionView(session: session)) {
                        Text("Join Session")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(12)
                    }
                } else {
                    NavigationLink(destination: MapSelectionView(session: session)) {
                        Text("Get Location")
                            .font(AppTheme.Typography.subheadline)
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
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.gray)
                Text(date.split(separator: " ").last ?? "")
                    .font(AppTheme.Typography.headline)
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                Text(time)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(AppTheme.Typography.badge)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) on \(date) at \(time)")
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
                                .font(AppTheme.Typography.subheadline)
                            Spacer()
                            StatusBadge.sessionStatus(session.status)
                        }
                        
                        Text("with \(session.instructorName)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 8) {
                            Label(session.date, systemImage: "calendar")
                            Text("•")
                            Text(session.time)
                        }
                        .font(AppTheme.Typography.caption2)
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
                                    .font(AppTheme.Typography.caption2)
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
            .accessibilityElement(children: .combine)
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
                    .font(AppTheme.Typography.subheadline)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTheme.Typography.caption2)
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

// MARK: - Empty State

struct EmptySessionsView: View {
    let filter: String

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.08))
                    .frame(width: 110, height: 110)
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary, AppTheme.Colors.primary.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text(headline)
                    .font(AppTheme.Typography.headline)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            NavigationLink(destination: SkillMatchesView()) {
                Text("Find a Session")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(14)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 60)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(headline + ". " + subtitle)
    }

    private var icon: String {
        switch filter {
        case "Upcoming": return "calendar.badge.plus"
        case "Cancelled": return "calendar.badge.exclamationmark"
        case "Completed": return "checkmark.seal.fill"
        default:          return "calendar"
        }
    }

    private var headline: String {
        switch filter {
        case "Upcoming":  return "No Upcoming Sessions"
        case "Cancelled": return "No Cancelled Sessions"
        case "Completed": return "No Completed Sessions Yet"
        default:          return "No Sessions Yet"
        }
    }

    private var subtitle: String {
        switch filter {
        case "Upcoming":  return "Book a session with a skill match to get started."
        case "Cancelled": return "You haven't cancelled any sessions. Great commitment!"
        case "Completed": return "Complete your first session to see it here."
        default:          return "Your sessions will appear here once you book one."
        }
    }
}
