import SwiftUI
import FirebaseCore
import FirebaseAuth
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Force-initialize FirebaseManager
        let manager = FirebaseManager.shared
        // Disable APNs requirement on Simulator
        manager.auth.settings?.isAppVerificationDisabledForTesting = true
        
        // Request Push Notification authorization
        NotificationManager.shared.requestAuthorization()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
    }
}

@main
struct SkillSpringApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

/// A SwiftUI View (not App) is required for @AppStorage to reliably re-render
/// when UserDefaults changes — this is the root login/logout gate.
struct RootCoordinatorView: View {
    @AppStorage("skillspryng.isLoggedIn") var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            LaunchView()
        }
    }
}
