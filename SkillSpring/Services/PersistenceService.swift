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
            localUser.profileImageURL = user.profileImageURL
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
}
