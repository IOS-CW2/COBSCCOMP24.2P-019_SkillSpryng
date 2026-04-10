import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            NavigationView {
                DiscoverView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("HOME", systemImage: "house.fill")
            }
            .tag(0)
            
            // Tab 2: Sessions
            NavigationView {
                MySessionsView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("SESSIONS", systemImage: "calendar")
            }
            .tag(1)
            
            // Tab 3: Chat
            NavigationView {
            NotificationsView()
                .navigationTitle("")
                .navigationBarHidden(true)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("CHAT", systemImage: "message.fill")
            }
            .tag(2)
            
            // Tab 4: Rewards
            NavigationView {
                RewardsTabView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("REWARDS", systemImage: "crown.fill")
            }
            .tag(3)
            
            // Tab 5: Profile
            NavigationView {
                ProfileView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("PROFILE", systemImage: "person.fill")
            }
            .tag(4)
        }
        .accentColor(AppTheme.Colors.primary) // Brand Green
    }
}

// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
