import Foundation
import UserNotifications
import Combine

@MainActor
/// Manages local notification authorization, scheduling, and category actions.
///
/// Handles session reminder alerts, booking confirmations, safety alerts,
/// and app onboarding notifications.
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    // MARK: - Notification Category & Action IDs
    private let sessionReminderCategoryID = "SESSION_REMINDER"
    private let joinSessionActionID       = "JOIN_SESSION"
    private let dismissActionID           = "DISMISS"

    private init() {}

    // MARK: - Authorisation

    /// Request permission and register actionable notification categories.
    /// Called once from AppDelegate on launch.
    func requestAuthorization() {
        // ── SESSION_REMINDER Category ──────────────────────────────────────
        // "Join Session" deep-links the user directly to the Sessions tab.
        let joinAction = UNNotificationAction(
            identifier: joinSessionActionID,
            title: "Join Session",
            options: [.foreground]
        )
        let dismissAction = UNNotificationAction(
            identifier: dismissActionID,
            title: "Dismiss",
            options: [.destructive]
        )
        let sessionCategory = UNNotificationCategory(
            identifier: sessionReminderCategoryID,
            actions: [joinAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        // ── SAFETY_ALERT Category ──────────────────────────────────────────
        // Shown when the user exits a geofence. Allows a single-tap response
        // so that the 5-minute escalation timer can be cancelled without
        // unlocking the device (foreground not required for "I'm Safe").
        let imSafeAction = UNNotificationAction(
            identifier: "IM_SAFE",
            title: "I'm Safe ✅",
            options: [.foreground]          // Opens app so user can confirm
        )
        let needHelpAction = UNNotificationAction(
            identifier: "NEED_HELP",
            title: "I Need Help 🚨",
            options: [.foreground, .destructive]
        )
        let safetyCategory = UNNotificationCategory(
            identifier: "SAFETY_ALERT",
            actions: [imSafeAction, needHelpAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([sessionCategory, safetyCategory])

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            if let error = error {
                print("Notification auth error: \(error.localizedDescription)")
            }
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Session Reminder

    /// Schedules a reminder with a "Join Session" action button 30 minutes before the session.
    /// - Parameters:
    ///   - identifier: A stable ID so we can cancel this specific reminder if booked session is cancelled.
    ///   - sessionTitle: e.g. "Advanced Creative Strategy"
    ///   - instructorName: e.g. "Sarah Thompson"
    ///   - sessionDate: The actual `Date` the session starts.
    func scheduleSessionReminder(
        identifier: String = UUID().uuidString,
        sessionTitle: String,
        instructorName: String,
        sessionDate: Date
    ) {
        guard isAuthorized else { return }

        // Fire 30 minutes before session
        let reminderDate = sessionDate.addingTimeInterval(-30 * 60)
        guard reminderDate > Date() else { return } // Don't schedule if already past

        let content = UNMutableNotificationContent()
        content.title = "Session starting in 30 mins 🎓"
        content.body  = "\(sessionTitle) with \(instructorName)"
        content.sound = .defaultCritical
        content.badge = 1
        content.categoryIdentifier = sessionReminderCategoryID
        content.userInfo = ["sessionTitle": sessionTitle, "instructor": instructorName]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "reminder-\(identifier)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Failed to schedule session reminder: \(error)") }
        }
    }

    // MARK: - Booking Confirmed

    /// Fires immediately (1 second delay) when a paid booking is confirmed.
    func scheduleBookingConfirmation(sessionTitle: String, instructorName: String, time: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Booking Confirmed ✅"
        content.body  = "\(sessionTitle) with \(instructorName) at \(time)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Failed to schedule booking confirmation: \(error)") }
        }
    }

    func scheduleMatchAccepted(requesterName: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Match Accepted ✅"
        content.body  = "You accepted the request from \(requesterName)."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "match.accepted.\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Failed to schedule match accepted notification: \(error)") }
        }
    }

    func scheduleMatchDeclined(requesterName: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Match Declined"
        content.body  = "You declined the request from \(requesterName)."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "match.declined.\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Failed to schedule match declined notification: \(error)") }
        }
    }

    func scheduleMatchCancelled(recipientName: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Match Request Cancelled"
        content.body  = "Your request to \(recipientName) has been cancelled."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "match.cancelled.\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Failed to schedule match cancelled notification: \(error)") }
        }
    }

    // MARK: - Booking Request Sent

    /// Fires immediately when a session request is sent to an instructor.
    func scheduleBookingRequestSent(instructorName: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Request Sent 📬"
        content.body  = "Waiting for \(instructorName) to accept. You'll be notified within 24 hours."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Failed to schedule request-sent notification: \(error)") }
        }
    }

    /// Fires immediately when a session is cancelled by the user or instructor.
    func scheduleSessionCancelled(
        sessionId: String,
        sessionTitle: String? = nil,
        instructorName: String? = nil
    ) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Session Cancelled"
        if let title = sessionTitle, let instructor = instructorName {
            content.body = "Your session '\(title)' with \(instructor) has been cancelled."
        } else if let title = sessionTitle {
            content.body = "Your session '\(title)' has been cancelled."
        } else {
            content.body = "Your session has been cancelled."
        }
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "session.cancelled.\(sessionId)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Failed to schedule cancellation notification: \(error)") }
        }
    }

    // MARK: - Welcome Notification

    /// Fires 3 seconds after the user first logs in — a warm welcome message.
    /// The notification is only scheduled once, but the one-time key is stored
    /// even if notification permission is not currently granted.
    func scheduleWelcomeNotification(userName: String) {
        let key = "skillspryng.welcomeNotificationSent"
        guard !UserDefaults.standard.bool(forKey: key) else { return }

        UserDefaults.standard.set(true, forKey: key)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["welcome"])

        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Welcome to SkillSpryng 🌱"
        content.body  = "Hi \(userName)! Start by exploring skills near you or listing what you can teach."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "welcome", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Failed to schedule welcome notification: \(error)") }
        }
    }

    // MARK: - Geofence Safety Alert

    /// Fires a critical-sound safety alert with "I'm Safe" / "I Need Help" action buttons.
    /// Uses the SAFETY_ALERT category registered at launch so action buttons are visible
    /// even on the lock screen.
    /// - Parameters:
    ///   - sessionId: Used to correlate the notification with the active session.
    ///   - userName: The user's first name shown in the notification body.
    func scheduleGeofenceSafetyAlert(sessionId: String, userName: String) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Are you safe, \(userName)?"
        content.body  = "You've moved away from your session location. Please confirm your safety."
        content.sound = .defaultCritical
        content.badge = 1
        content.categoryIdentifier = "SAFETY_ALERT"
        content.userInfo = ["sessionId": sessionId]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "safety.alert.\(sessionId)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("[NotificationManager] Safety alert error: \(error)") }
        }
    }

    /// MARK: - Emergency Alerts

    /// Fires immediately when the user confirms that family and authorities should be notified.
    func scheduleEmergencyContactAlert(sessionTitle: String? = nil) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Emergency Alert Sent 🚨"
        if let sessionTitle = sessionTitle {
            content.body = "Your emergency contacts and local authorities have been notified for '\(sessionTitle)'."
        } else {
            content.body = "Your emergency contacts and local authorities have been notified."
        }
        content.sound = .defaultCritical
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "emergency.alert.\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("[NotificationManager] Emergency alert error: \(error)") }
        }
    }

    // MARK: - Cancellation & Badge

    /// Cancel a specific pending notification (e.g. if a session is cancelled).
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Cancel all pending notifications — used on logout.
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }

    /// Clear badge count — call when the user opens the app.
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }
    
    /// Fires a motivational notification after the user successfully upgrades to SkillSpryng Pro.
    func schedulePremiumWelcomeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Welcome to SkillSpryng Pro! 👑"
        content.body = "You now have unlimited matches, priority discovery, and access to host paid sessions. Let's grow!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "pro.welcome", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
