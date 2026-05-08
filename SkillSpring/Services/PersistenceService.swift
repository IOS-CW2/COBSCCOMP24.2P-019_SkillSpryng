import CoreData
import Foundation

/// PersistenceService acts as a bridge between the User Swift struct and the Core Data LocalUser entity.
/// This allows for offline access and faster launch times by caching the user profile locally.
class PersistenceService {
    static let shared = PersistenceService()
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    /// Saves or updates the local user cache with the provided User data.
    ///
    /// The method fetches the existing LocalUser record if it exists, then maps
    /// fields from the User struct into the Core Data entity.
    /// Array values are stored as comma-separated strings for simplicity.
    func saveUser(_ user: User) {
        let fetchRequest: NSFetchRequest<LocalUser> = NSFetchRequest<LocalUser>(entityName: "LocalUser")
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            let localUser: LocalUser
            if let existing = results.first {
                localUser = existing
            } else {
                localUser = LocalUser(context: context)
            }
            
            // Map fields from Swift struct to Core Data entity
            localUser.id = user.id
            localUser.fullName = user.fullName
            localUser.phoneNumber = user.phoneNumber
            localUser.experienceLevel = user.experienceLevel
            localUser.location = user.location
            localUser.bio = user.bio
            let incomingProfileImageURL = user.profileImageURL.trimmingCharacters(in: .whitespacesAndNewlines)
            if !incomingProfileImageURL.isEmpty {
                localUser.profileImageURL = user.profileImageURL
            } else if localUser.profileImageURL == nil || localUser.profileImageURL?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
                localUser.profileImageURL = user.profileImageURL
            }
            localUser.role = user.role
            localUser.level = Int16(user.level)
            localUser.karmaPoints = Int32(user.karmaPoints)
            localUser.sessionsCount = Int32(user.sessionsCount)
            localUser.rating = user.rating
            localUser.awardsCount = Int32(user.awardsCount)
            localUser.walletBalance = Int32(user.walletBalance)
            localUser.isPro = user.isPremium
            localUser.isChildMode = user.isChildMode
            localUser.profileCompleteness = Int16(user.profileCompleteness)
            
            // Store arrays as comma-separated strings for simplicity in Core Data
            localUser.skillsToTeach = user.skillsToTeach.joined(separator: ", ")
            localUser.skillsToLearn = user.skillsToLearn.joined(separator: ", ")
            
            try context.save()
            print("SUCCESS: User profile cached in Core Data.")
        } catch {
            print("ERROR: Failed to save to Core Data: \(error)")
        }
    }

    /// Fetches the cached user from Core Data.
    /// Returns nil if no user is cached.
    func fetchUser() -> User? {
        let fetchRequest: NSFetchRequest<LocalUser> = NSFetchRequest<LocalUser>(entityName: "LocalUser")
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            guard let localUser = results.first else { return nil }
            
            // Map back from Core Data entity to Swift struct
            var user = User(fullName: localUser.fullName ?? "")
            user.id = localUser.id
            user.phoneNumber = localUser.phoneNumber ?? ""
            user.skillsToTeach = localUser.skillsToTeach?.components(separatedBy: ", ").filter { !$0.isEmpty } ?? []
            user.skillsToLearn = localUser.skillsToLearn?.components(separatedBy: ", ").filter { !$0.isEmpty } ?? []
            user.experienceLevel = localUser.experienceLevel ?? ""
            user.location = localUser.location ?? ""
            user.bio = localUser.bio ?? ""
            user.profileImageURL = localUser.profileImageURL ?? ""
            user.role = localUser.role ?? "Member"
            user.level = Int(localUser.level)
            user.karmaPoints = Int(localUser.karmaPoints)
            user.sessionsCount = Int(localUser.sessionsCount)
            user.rating = localUser.rating
            user.awardsCount = Int(localUser.awardsCount)
            user.walletBalance = Int(localUser.walletBalance)
            user.isPremium = localUser.isPro
            user.isChildMode = localUser.isChildMode
            user.profileCompleteness = Int(localUser.profileCompleteness)
            
            return user
        } catch {
            print("ERROR: Failed to fetch from Core Data: \(error)")
            return nil
        }
    }

    /// Clears the local user cache. Called on logout.
    func clearCache() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LocalUser")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("SUCCESS: Core Data user cache cleared.")
        } catch {
            print("ERROR: Failed to clear Core Data cache: \(error)")
        }
    }
    
    /// Updates the isPro flag on the locally cached Core Data user — called after Pro purchase.
    func updateLocalUserPro(isPremium: Bool) {
        let fetchRequest: NSFetchRequest<LocalUser> = NSFetchRequest<LocalUser>(entityName: "LocalUser")
        fetchRequest.fetchLimit = 1
        do {
            if let localUser = try context.fetch(fetchRequest).first {
                localUser.isPro = isPremium
                try context.save()
                print("[Core Data] isPro updated to \(isPremium)")
            }
        } catch {
            print("[Core Data] Failed to update isPro: \(error)")
        }
    }

    // MARK: - Session Cache

    /// Saves or updates a Session in the local Core Data store.
    /// Uses the session `id` as the upsert key.
    func saveSession(_ session: Session) {
        let fetchRequest: NSFetchRequest<LocalSession> = NSFetchRequest<LocalSession>(entityName: "LocalSession")
        fetchRequest.predicate = NSPredicate(format: "id == %@", session.id)
        fetchRequest.fetchLimit = 1

        do {
            let results = try context.fetch(fetchRequest)
            let local: LocalSession = results.first ?? LocalSession(context: context)

            local.id             = session.id
            local.title          = session.title
            local.instructorName = session.instructorName
            local.instructorRole = session.instructorRole
            local.date           = session.date
            local.time           = session.time
            local.duration       = session.duration
            local.location       = session.location
            local.status         = session.status.rawValue
            local.sessionType    = session.type.rawValue
            local.category       = session.category
            local.notes          = session.notes
            local.scheduledAt    = session.scheduledAt
            local.createdAt      = session.createdAt
            local.calendarEventId = session.calendarEventId

            try context.save()
            print("[Core Data] ✅ Session cached: \(session.title)")
        } catch {
            print("[Core Data] ❌ Failed to save session: \(error)")
        }
    }

    /// Returns all cached sessions ordered by scheduledAt descending.
    func fetchSessions() -> [Session] {
        let fetchRequest: NSFetchRequest<LocalSession> = NSFetchRequest<LocalSession>(entityName: "LocalSession")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "scheduledAt", ascending: false)]

        do {
            return try context.fetch(fetchRequest).compactMap { local -> Session? in
                guard let id    = local.id,
                      let title = local.title else { return nil }
                var session = Session(
                    title:          title,
                    instructorName: local.instructorName ?? "",
                    instructorRole: local.instructorRole ?? "",
                    instructorId:   nil,  // TODO: Add to Core Data model
                    date:           local.date ?? "",
                    time:           local.time ?? "",
                    duration:       local.duration ?? "",
                    location:       local.location,
                    distance:       nil,
                    timeRemaining:  nil,
                    status:         SessionStatus(rawValue: local.status ?? "") ?? .upcoming,
                    type:           SessionType(rawValue: local.sessionType ?? "") ?? .online,
                    category:       local.category ?? "Session",
                    rating:         nil,
                    notes:          local.notes
                )
                session.id              = id
                session.scheduledAt     = local.scheduledAt ?? Date()
                session.createdAt       = local.createdAt ?? Date()
                session.calendarEventId = local.calendarEventId
                return session
            }
        } catch {
            print("[Core Data] ❌ Failed to fetch sessions: \(error)")
            return []
        }
    }

    /// Deletes all cached sessions — called on logout.
    func clearSessionCache() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LocalSession")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("[Core Data] ✅ Session cache cleared.")
        } catch {
            print("[Core Data] ❌ Failed to clear session cache: \(error)")
        }
    }
}
