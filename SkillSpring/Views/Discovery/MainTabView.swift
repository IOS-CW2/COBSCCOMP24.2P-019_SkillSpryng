import SwiftUI

/// Main tab bar for the SkillSpryng app.
///
/// Hosts the core navigation tabs: Home, Sessions, Messages, Rewards, and Profile.
struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            NavigationStack {
                DiscoverView()
            }
            .tabItem {
                Label("HOME", systemImage: "house.fill")
            }
            .tag(0)
            .accessibilityIdentifier("homeTab")
            
            // Tab 2: Sessions
            NavigationStack {
                MySessionsView()
            }
            .tabItem {
                Label("SESSIONS", systemImage: "calendar")
            }
            .tag(1)
            .accessibilityIdentifier("sessionsTab")
            
            // Tab 3: Chat
            NavigationStack {
            NotificationsView()
                .navigationTitle("")
                .navigationBarHidden(true)
            }
            .tabItem {
                Label("MESSAGES", systemImage: "message.fill")
            }
            .tag(2)
            .accessibilityIdentifier("messagesTab")
            
            // Tab 4: Rewards
            NavigationStack {
                RewardsTabView()
            }
            .tabItem {
                Label("REWARDS", systemImage: "crown.fill")
            }
            .tag(3)
            .accessibilityIdentifier("rewardsTab")
            
            // Tab 5: Profile
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("PROFILE", systemImage: "person.fill")
            }
            .tag(4)
        }
        .accentColor(AppTheme.Colors.primary)
        // Deep-link: tapping "Join Session" on a notification banner opens Sessions tab
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("skillspryng.openSessionsTab"))) { _ in
            selectedTab = 1
        }
        .task {
            // Force seed on launch for returning users.
            // DataSeeder is idempotent and will skip collections that already exist.
            await DataSeeder.shared.seedAll()
        }
    }
}


// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
