import SwiftUI

// MARK: - NotificationsView
// Root Messages tab view that combines conversation previews, search/filter controls,
// quick navigation to matches, calendar access, and notification-style cards.
struct NotificationsView: View {
    @StateObject private var viewModel = MessagesViewModel()
    @State private var selectedConversation: Conversation?
    @State private var navigateToMatches  = false
    @State private var navigateToCalendar = false
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                    // Standardized AppHeader (No back button for Root Tab)
                    AppHeader(
                        title: "Messages",
                        showBackButton: false,
                        actionText: "Matches",
                        action: { navigateToMatches = true }
                    )
                    .padding(.top, 8)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // Title & Calendar
                            HStack {
                                Text("Messages")
                                    .font(AppTheme.Typography.largeTitle)
                                Spacer()
                                // CALENDAR button → navigates to MySessionsView
                                Button(action: { navigateToCalendar = true }) {
                                    Label("CALENDAR", systemImage: "calendar")
                                        .font(AppTheme.Typography.badge)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(AppTheme.Colors.primary.opacity(0.1))
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .cornerRadius(20)
                                }
                                .accessibilityLabel("View my session calendar")
                                .accessibilityHint("Double-tap to open your upcoming sessions")
                            }
                            .padding(.horizontal)
                            
                            // Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Search conversations...", text: $viewModel.searchText)
                                    .font(AppTheme.Typography.body)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            // Filters
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.filters, id: \.self) { filter in
                                        Button(action: { viewModel.selectedFilter = filter }) {
                                            Text(filter)
                                                .font(AppTheme.Typography.subheadline)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(viewModel.selectedFilter == filter ? AppTheme.Colors.primary : Color(.systemGray6))
                                                .foregroundColor(viewModel.selectedFilter == filter ? .white : .gray)
                                                .cornerRadius(20)
                                        }
                                        .accessibilityAddTraits(viewModel.selectedFilter == filter ? .isSelected : [])
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Today Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("TODAY")
                                    .font(AppTheme.Typography.badge)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                            let todayConversations = viewModel.todayConversations

                                if viewModel.isTodayEmpty {
                                    EmptyMessagesView(searchText: viewModel.searchText)
                                        .padding(.top, 40)
                                } else {
                                    ForEach(todayConversations) { conv in
                                        NavigationLink(destination: ChatDetailView(conversation: conv)) {
                                            ConversationCard(conversation: conv)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                
                                // Mock Match & Session Notifications
                                NotificationItemCard(
                                    title: "New Match: Marcus Chen",
                                    subtitle: "Both of you are interested in Advanced Python Design Patterns.",
                                    time: "1H AGO",
                                    imageName: "instructor1",
                                    iconBackground: AppTheme.Colors.primary,
                                    statusIcon: "heart.fill"
                                )
                                .padding(.horizontal)
                                
                                NotificationItemCard(
                                    title: "Session Reminder",
                                    subtitle: "Your 'Digital Strategy' workshop starts in 30 minutes. Be ready!",
                                    time: "3H AGO",
                                    imageName: nil,
                                    iconBackground: .orange,
                                    statusIcon: "calendar.badge.clock"
                                )
                                .padding(.horizontal)
                            }
                            
                            // Yesterday Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("YESTERDAY")
                                    .font(AppTheme.Typography.badge)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                NotificationItemCard(
                                    title: "Badge Earned: High Growth",
                                    subtitle: "You've successfully completed 5 mentorship hours this week.",
                                    time: "YESTERDAY",
                                    imageName: nil,
                                    iconBackground: Color(hex: "27E246"),
                                    statusIcon: "rosette"
                                )
                                .padding(.horizontal)
                                
                                ForEach(viewModel.yesterdayConversations) { conv in
                                    NavigationLink(destination: ChatDetailView(conversation: conv)) {
                                        ConversationCard(conversation: conv)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            Spacer().frame(height: 100)
                        }
                        .padding(.top)
                    }
                }
                
                // FAB
                Button(action: { navigateToMatches = true }) {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(16)
                        .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .accessibilityIdentifier("matchesButton")
                .padding()
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToMatches) {
            MyMatchesInboxView()
        }
        .navigationDestination(isPresented: $navigateToCalendar) {
            MySessionsView()
        }
    }
}

// MARK: - ConversationCard
/// Displays a conversation preview row for the Messages feed.
/// Includes avatar, recent message text, timestamp, and unread badge state.
struct ConversationCard: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                Image(conversation.participant.profileImageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                Circle()
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Image(systemName: "message.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.white)
                    )
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.participant.fullName)
                    .font(AppTheme.Typography.headline)
                Text(conversation.lastMessage)
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(conversation.lastMessageTime)
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(conversation.unreadCount > 0 ? AppTheme.Colors.primary : .gray)
                
                if conversation.unreadCount > 0 {
                    Text("\(conversation.unreadCount)")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(AppTheme.Colors.primary)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - NotificationItemCard
/// A stylized notification card used for match and session updates.
/// Combines an icon/avatar, title, subtitle, and timestamp for quick scanning.
struct NotificationItemCard: View {
    let title: String
    let subtitle: String
    let time: String
    let imageName: String?
    let iconBackground: Color
    let statusIcon: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                if let img = imageName {
                    Image(img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(iconBackground.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .overlay(Image(systemName: statusIcon).foregroundColor(iconBackground))
                }
                
                if imageName != nil {
                    Circle()
                        .fill(iconBackground)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Image(systemName: statusIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 8, height: 8)
                                .foregroundColor(.white)
                        )
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(time)
                .font(AppTheme.Typography.badge)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Empty State

struct EmptyMessagesView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.08))
                    .frame(width: 110, height: 110)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary, AppTheme.Colors.primary.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("No Results Found")
                    .font(AppTheme.Typography.headline)

                Text("No conversations match \"\(searchText)\".\nTry a different name or keyword.")
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No conversations match \(searchText).")
    }
}
