import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    
    let filters = ["All", "Unread", "Mentors", "Groups"]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding()
                    }
                    Spacer()
                    Text("Notifications")
                        .font(.headline)
                        .bold()
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0).padding()
                }
                .padding(.top, 10)
                .background(Color.white)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Header
                        HStack {
                            Text("Messages")
                                .font(.system(size: 34, weight: .heavy))
                            
                            Spacer()
                            
                            Button(action: {
                                // Calendar Action
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                    Text("CALENDAR")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(AppTheme.Colors.primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(AppTheme.Colors.primary.opacity(0.15))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Search Bar
                        HStack {
                            TextField("Search conversations...", text: $searchText)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // Filter Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(filters, id: \.self) { filter in
                                    Button(action: { selectedFilter = filter }) {
                                        Text(filter)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(selectedFilter == filter ? .black : .black.opacity(0.8))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(selectedFilter == filter ? AppTheme.Colors.primary : Color(.systemGray5))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // TODAY Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TODAY")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                                .padding(.top, 4)
                            
                            NotificationCard(
                                title: "Sim V sent you a message",
                                subtitle: "\"The session on UI/UX wa...",
                                time: "2MIN AGO",
                                isUnread: true,
                                iconName: "person.fill",
                                badgeName: "message.fill",
                                unreadCount: 1,
                                timeColor: AppTheme.Colors.primary
                            )
                            
                            NotificationCard(
                                title: "New Match: Marcus Chen",
                                subtitle: "Both of you are interested in\nAdvanced Python Design Patterns.",
                                time: "1H AGO",
                                isUnread: false,
                                iconName: "person.fill",
                                badgeName: "heart.fill",
                                timeColor: Color.black.opacity(0.7)
                            )
                            
                            SystemNotificationCard(
                                title: "Session Reminder",
                                subtitle: "Your 'Digital Strategy' workshop\nstarts in 30 minutes. Be ready!",
                                time: "3H AGO",
                                iconName: "calendar.badge.clock",
                                iconBackgroundColor: Color.orange.opacity(0.15),
                                iconForegroundColor: .orange
                            )
                        }
                        
                        // YESTERDAY Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("YESTERDAY")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                            
                            SystemNotificationCard(
                                title: "Badge Earned: High Growth",
                                subtitle: "You've successfully completed 5\nmentorship hours this week.",
                                time: "YESTERDAY",
                                iconName: "rosette",
                                iconBackgroundColor: AppTheme.Colors.primary.opacity(0.15),
                                iconForegroundColor: AppTheme.Colors.primary
                            )
                            
                            NotificationCard(
                                title: "Aria Sterling",
                                subtitle: "\"Thanks for the resources you shared\nyesterday!\"",
                                time: "YESTERDAY",
                                isUnread: false,
                                iconName: "person.fill",
                                badgeName: "message.fill",
                                timeColor: Color.black.opacity(0.7)
                            )
                        }
                        
                        Spacer(minLength: 120) // Space for TabBar and FAB
                    }
                }
                .background(Color(red: 0.98, green: 0.98, blue: 0.99))
            }
            
            // Floating Action Button
            Button(action: {
                // Compose New Message
            }) {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(16)
                    .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 30) // Positioned just above where the custom tab bar would be
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Subviews

struct NotificationCard: View {
    var title: String
    var subtitle: String
    var time: String
    var isUnread: Bool
    var iconName: String
    var badgeName: String
    var unreadCount: Int = 0
    var timeColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar with Badge
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: iconName)
                            .foregroundColor(.gray)
                    ) // Placeholder for real user images
                
                // Small indicator badge
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(AppTheme.Colors.primary)
                        .frame(width: 16, height: 16)
                    Image(systemName: badgeName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: 4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(time)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(timeColor)
                
                if isUnread && unreadCount > 0 {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 22, height: 22)
                        Text("\(unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            HStack {
                if isUnread {
                    Rectangle()
                        .fill(AppTheme.Colors.primary)
                        .frame(width: 4)
                        .cornerRadius(2, corners: [.topLeft, .bottomLeft])
                }
                Spacer()
            }
        )
        .padding(.horizontal, 20)
    }
}

struct SystemNotificationCard: View {
    var title: String
    var subtitle: String
    var time: String
    var iconName: String
    var iconBackgroundColor: Color
    var iconForegroundColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(iconForegroundColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(time)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.black.opacity(0.7))
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// Helper for specific corner rounding
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
