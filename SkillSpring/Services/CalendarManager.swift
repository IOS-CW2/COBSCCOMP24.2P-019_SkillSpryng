import Foundation
import EventKit
import Combine

class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()
    
    @Published var isAuthorized: Bool = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        DispatchQueue.main.async {
            self.isAuthorized = status == .authorized
        }
    }
    
    func requestAccess() async -> Bool {
        do {
            let success = try await eventStore.requestAccess(to: .event)
            DispatchQueue.main.async {
                self.isAuthorized = success
            }
            return success
        } catch {
            print("Failed to request calendar access: \(error.localizedDescription)")
            return false
        }
    }
    
    func addEvent(title: String, startDate: Date, endDate: Date, notes: String? = nil) async -> (Bool, String?) {
        guard isAuthorized else {
            return (false, "Calendar access not authorized.")
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return (true, nil)
        } catch {
            return (false, error.localizedDescription)
        }
    }
}
