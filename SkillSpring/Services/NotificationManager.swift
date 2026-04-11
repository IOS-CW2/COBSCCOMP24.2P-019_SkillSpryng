import Foundation
import UserNotifications
import Combine

@MainActor
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
        // Define "Join Session" action on reminder notifications
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
        UNUserNotificationCenter.current().setNotificationCategories([sessionCategory])

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

    // MARK: - Welcome Notification

    /// Fires 3 seconds after the user first logs in — a warm welcome message.
    func scheduleWelcomeNotification(userName: String) {
        guard isAuthorized else { return }

        // Only send once, ever
        let key = "skillspryng.welcomeNotificationSent"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

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
}
