import SwiftUI
import FirebaseCore
import FirebaseAuth
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()


        // Force-initialize FirebaseManager
        let manager = FirebaseManager.shared
#if DEBUG
        // Disable APNs OTP verification on Simulator / Debug builds only.
        // MUST NOT be enabled in Release — it bypasses real phone-number verification.
        manager.auth.settings?.isAppVerificationDisabledForTesting = true
#endif
        
        // Set delegate BEFORE requesting authorization so no notifications are missed
        UNUserNotificationCenter.current().delegate = self
        
        // Request Push Notification authorization and register categories
        NotificationManager.shared.requestAuthorization()
        
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Show notification banners even when the app is in the FOREGROUND
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handle action button taps (e.g. "Join Session" from a reminder notification)
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionID = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        
        if actionID == "JOIN_SESSION" {
            // Deep-link to Sessions tab when user taps "Join Session"
            // Post a notification that MainTabView listens to
            NotificationCenter.default.post(
                name: Notification.Name("skillspryng.openSessionsTab"),
                object: nil,
                userInfo: userInfo
            )
        }
        completionHandler()
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
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .task {
                    // StoreKit 2: Load products and silently restore Pro status on every launch
                    async let products: () = StoreKitService.shared.loadProducts()
                    async let status: () = StoreKitService.shared.checkSubscriptionStatus()
                    _ = await (products, status)
                }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                // Clear badge count whenever the user opens the app
                NotificationManager.shared.clearBadge()
            }
        }
    }
}

/// A SwiftUI View (not App) is required for @AppStorage to reliably re-render
/// when UserDefaults changes — this is the root login/logout gate.
struct RootCoordinatorView: View {
    @AppStorage("skillspryng.isLoggedIn") var isLoggedIn = false
    @State private var previouslyLoggedIn = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView()
            } else {
                LaunchView()
            }
        }
        .onChange(of: isLoggedIn) { loggedIn in
            if loggedIn && !previouslyLoggedIn {
                // First time logging in this session — fire welcome notification
                let userName = PersistenceService.shared.fetchUser()?.fullName ?? "there"
                NotificationManager.shared.scheduleWelcomeNotification(userName: userName)
            }
            previouslyLoggedIn = loggedIn
        }
    }
}
