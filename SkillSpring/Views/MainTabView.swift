import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home / Discover
            NavigationView {
                DiscoverView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Tab 2: Matches / Sessions
            NavigationView {
                MatchesListView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Sessions", systemImage: "calendar")
            }
            .tag(1)
            
            // Tab 3: Map Selection
            NavigationView {
                MapSelectionView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Map", systemImage: "mappin.and.ellipse")
            }
            .tag(2)
            
            // Tab 4: Analytics / Learning Pulse
            NavigationView {
                AnalyticsView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Analytics", systemImage: "chart.bar.fill")
            }
            .tag(3)
            
            // Tab 5: Profile / Match Detail
            NavigationView {
                MatchDetailView(profile: MockDataProvider.shared.elenaProfile)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Profile", systemImage: "person.fill")
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
