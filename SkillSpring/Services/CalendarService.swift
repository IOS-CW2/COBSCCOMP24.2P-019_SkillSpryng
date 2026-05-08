import Foundation
import EventKit
import CoreLocation
import Combine
import UIKit

/// Manages Calendar access and event scheduling for SkillSpryng sessions.
///
/// Supports adding session events, updating or deleting existing events,
/// and checking available time slots before booking.
class CalendarService: ObservableObject {
    
    static let shared = CalendarService()
    private let eventStore = EKEventStore()
    @Published var accessStatus: EKAuthorizationStatus = .notDetermined
    
    /// `true` when the user has permanently denied calendar access.
    /// Drives PermissionDeniedView(.calendar) in SessionBookingView.
    @Published var calendarDenied: Bool = false
    
    private init() {
        self.accessStatus = EKEventStore.authorizationStatus(for: .event)
        self.calendarDenied = (self.accessStatus == .denied || self.accessStatus == .restricted)
    }
    
    // SIMULATOR TESTING:
    // 1. Open Calendar app in Simulator
    // 2. Add 2-3 events on different dates
    // 3. Run SkillSpryng and go to Schedule Session
    // 4. Select the same date as your test events
    // 5. Verify those time slots appear greyed out
    // 6. Test Add to Calendar in SessionSuccessView
    // 7. Open Calendar app — event should appear
    // If event doesn't appear: force close Calendar and reopen it
    
    // FUNCTION 1: requestAccess
    /// Asks the user for calendar permissions and updates local state.
    /// This should be called once before trying to write events.
    func requestAccess() async {
        if #available(iOS 17, *) {
            let granted = (try? await eventStore.requestFullAccessToEvents()) ?? false
            await MainActor.run {
                self.accessStatus   = granted ? .fullAccess : .denied
                self.calendarDenied = !granted
            }
        } else {
            let granted = await withCheckedContinuation { c in
                eventStore.requestAccess(to: .event) { ok, _ in c.resume(returning: ok) }
            }
            await MainActor.run {
                self.accessStatus   = granted ? .authorized : .denied
                self.calendarDenied = !granted
            }
        }
        if calendarDenied {
            print("[CalendarService] ⚠️ Calendar denied — show PermissionDeniedView(.calendar)")
        }
    }

    /// Deep-links to SkillSpryng's Calendar settings when the user has denied access.
    func openSettingsForCalendar() { openAppSettings() }

    
    // FUNCTION 2: addSessionToCalendar
    func addSessionToCalendar(
        title: String,
        instructorName: String,
        startDate: Date,
        durationMinutes: Int,
        format: String,
        locationName: String?,
        latitude: Double? = nil,
        longitude: Double? = nil,
        sessionId: String
    ) async -> String? {
        
        // Ensure access is granted before saving.
        // NOTE: The caller (UI layer) should have already requested access.
        // We skip re-requesting here to avoid a double-prompt bug where iOS
        // returns false on the second concurrent requestAccess() call.
        guard checkCalendarAccess() else {
            print("[CalendarService] Access not granted — skipping save.")
            return nil
        }
        
        // Handle Simulator Issue 1
        guard let defaultCalendar = eventStore.defaultCalendarForNewEvents ?? eventStore.calendars(for: .event).first else {
            print("No calendar available")
            return nil
        }
        
        // Step 4: Create EKEvent
        let event = EKEvent(eventStore: eventStore)
        event.title = "SkillSpryng: \(title) with \(instructorName)"
        event.startDate = startDate
        event.endDate = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: startDate) ?? startDate.addingTimeInterval(Double(durationMinutes * 60))
        event.calendar = defaultCalendar
        
        if format == "ONLINE" {
            event.notes = """
            📱 Online Session — SkillSpryng
            Open SkillSpryng app to join your session.
            Session ID: \(sessionId)
            Skill: \(title)
            Duration: \(durationMinutes) minutes
            """
        } else {
            event.location = locationName ?? "Agreed Location"
            event.notes = """
            📍 In-Person Session — SkillSpryng
            Meet at: \(locationName ?? "agreed location")
            Skill: \(title)
            Duration: \(durationMinutes) minutes
            Safety monitoring will be active during session.
            """
            
            // Appended Feature 1: Time-to-Leave Traffic Alerts via EKStructuredLocation
            if let lat = latitude, let lon = longitude {
                let structuredLocation = EKStructuredLocation(title: locationName ?? "Session Venue")
                structuredLocation.geoLocation = CLLocation(latitude: lat, longitude: lon)
                structuredLocation.radius = 500 // Map to geofence radius
                event.structuredLocation = structuredLocation
            }
        }
        
        // Appended Feature 2: Deep Link (Launch app from Apple Calendar)
        if let url = URL(string: "skillspryng://session/\(sessionId)") {
            event.url = url
        }
        
        // Step 5: Add reminders (30 minutes and 24 hours before)
        event.addAlarm(EKAlarm(relativeOffset: -1800))  // 30 minutes (matches session reminder notification)
        event.addAlarm(EKAlarm(relativeOffset: -86400)) // 24 hours
        
        // Step 6: Save and return identifier
        do {
            try eventStore.save(event, span: .thisEvent)
            
            // Force Calendar app to refresh (Simulator Issue 3)
            NotificationCenter.default.post(name: .EKEventStoreChanged, object: eventStore)
            
            return event.eventIdentifier
        } catch {
            print("Failed to save event: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Wrapper to pass directly with Session model if needed
    func addSessionToCalendar(session: Session, parsedStartDate: Date, parsedDuration: Int) async -> String? {
        return await addSessionToCalendar(
            title: session.title,
            instructorName: session.instructorName,
            startDate: parsedStartDate,
            durationMinutes: parsedDuration,
            format: session.type.rawValue,
            locationName: session.location,
            latitude: nil, // If session captures coordinates, pass them here
            longitude: nil,
            sessionId: session.id
        )
    }

    // FUNCTION 3: updateCalendarEvent
    /// Edits an existing calendar event by identifier and saves the changes.
    func updateCalendarEvent(identifier: String, newStartDate: Date, newDurationMinutes: Int, newLocation: String?) async -> Bool {
        guard let event = eventStore.event(withIdentifier: identifier) else { return false }
        
        event.startDate = newStartDate
        event.endDate = Calendar.current.date(byAdding: .minute, value: newDurationMinutes, to: newStartDate) ?? newStartDate.addingTimeInterval(Double(newDurationMinutes * 60))
        
        if let loc = newLocation {
            event.location = loc
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            return false
        }
    }
    
    // FUNCTION 4: deleteCalendarEvent
    /// Deletes a previously created SkillSpryng event from the calendar.
    func deleteCalendarEvent(identifier: String) async -> Bool {
        guard let event = eventStore.event(withIdentifier: identifier) else { return false }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
            return true
        } catch {
            return false
        }
    }
    
    // FUNCTION 5: addEventToCalendar (Generic Version)
    /// Adds a generic event to the user's calendar with a 1-hour reminder.
    func addEventToCalendar(title: String, startDate: Date, endDate: Date, location: String?, notes: String?) async -> String? {
        // Same fix: check without re-requesting to avoid double-prompt
        guard checkCalendarAccess() else { return nil }
        
        guard let defaultCalendar = eventStore.defaultCalendarForNewEvents ?? eventStore.calendars(for: .event).first else {
            return nil
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = location
        event.notes = notes
        event.calendar = defaultCalendar
        
        event.addAlarm(EKAlarm(relativeOffset: -3600)) // 1 hour
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return event.eventIdentifier
        } catch {
            return nil
        }
    }
    
    // FUNCTION 6: getBusyTimeSlots
    /// Returns all busy calendar intervals for the given date.
    func getBusyTimeSlots(on date: Date) -> [DateInterval] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        return events.map { DateInterval(start: $0.startDate, end: $0.endDate) }
    }
    
    // FUNCTION 7: isTimeSlotAvailable
    /// Checks whether a proposed session slot intersects any busy calendar intervals.
    func isTimeSlotAvailable(startTime: Date, durationMinutes: Int, busySlots: [DateInterval]) -> Bool {
        guard let endTime = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: startTime) else { return true }
        let proposedSlot = DateInterval(start: startTime, end: endTime)
        
        for busySlot in busySlots {
            if proposedSlot.intersects(busySlot) {
                return false
            }
        }
        return true
    }
    
    // FUNCTION 8: checkCalendarAccess
    /// Returns true when the app is allowed to write events to the Calendar.
    func checkCalendarAccess() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17.0, *) {
            return status == .fullAccess || status == .writeOnly
        } else {
            return status == .authorized
        }
    }
}
