import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var setupViewModel = SkillSetupViewModel()
    
    var body: some View {
        Group {
            if setupViewModel.isSetupComplete {
                MainTabView()
            } else {
                LaunchView()
                    .environmentObject(authViewModel)
                    .environmentObject(setupViewModel)
            }
        }
    }
}
