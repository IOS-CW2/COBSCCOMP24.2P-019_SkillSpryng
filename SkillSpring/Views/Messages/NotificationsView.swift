import SwiftUI

struct NotificationsView: View {
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var selectedConversation: Conversation?
    @State private var navigateToMatches = false
    
    let filters = ["All", "Unread", "Matches", "Groups"]
    
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
                                    .font(.system(size: 32, weight: .bold))
                                Spacer()
                                Button(action: { }) {
                                    Label("CALENDAR", systemImage: "calendar")
                                        .font(.system(size: 10, weight: .bold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(AppTheme.Colors.primary.opacity(0.1))
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Search conversations...", text: $searchText)
                                    .font(AppTheme.Typography.body)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            // Filters
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(filters, id: \.self) { filter in
                                        Button(action: { selectedFilter = filter }) {
                                            Text(filter)
                                                .font(.system(size: 14, weight: .medium))
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(selectedFilter == filter ? AppTheme.Colors.primary : Color(.systemGray6))
                                                .foregroundColor(selectedFilter == filter ? .white : .gray)
                                                .cornerRadius(20)
                                        }
                                        .accessibilityAddTraits(selectedFilter == filter ? .isSelected : [])
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Today Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("TODAY")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                            let todayConversations = MockDataProvider.shared.mockConversations.filter {
                                    ($0.participant.fullName == "Marcus Chen" || $0.participant.fullName == "Sim V") &&
                                    (searchText.isEmpty || $0.participant.fullName.localizedCaseInsensitiveContains(searchText) || $0.lastMessage.localizedCaseInsensitiveContains(searchText))
                                }

                                if todayConversations.isEmpty && !searchText.isEmpty {
                                    EmptyMessagesView(searchText: searchText)
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
                                    .font(.system(size: 12, weight: .bold))
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
                                
                                ForEach(MockDataProvider.shared.mockConversations) { conv in
                                    if conv.participant.fullName == "Aria Sterling" {
                                        NavigationLink(destination: ChatDetailView(conversation: conv)) {
                                            ConversationCard(conversation: conv)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            
                            Spacer().frame(height: 100)
                        }
                        .padding(.top)
                    }
                }
                
                // FAB
                Button(action: { }) {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(16)
                        .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding()
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToMatches) {
            MyMatchesInboxView()
        }
    }
}

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
                    .font(.system(size: 16, weight: .bold))
                Text(conversation.lastMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(conversation.lastMessageTime)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(conversation.unreadCount > 0 ? AppTheme.Colors.primary : .gray)
                
                if conversation.unreadCount > 0 {
                    Text("\(conversation.unreadCount)")
                        .font(.system(size: 10, weight: .bold))
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
                    .font(.system(size: 14, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 10, weight: .bold))
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
                    .font(.system(size: 18, weight: .bold))

                Text("No conversations match \"\(searchText)\".\nTry a different name or keyword.")
                    .font(.system(size: 14))
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
