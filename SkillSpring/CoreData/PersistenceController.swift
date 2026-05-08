import CoreData
import Combine

/// Manages the Core Data stack for the app.
///
/// This controller creates a shared persistent container and optionally
/// supports an in-memory store for previews or tests.
struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    /// Creates the Core Data container and loads the store.
    ///
    /// - Parameter inMemory: When true, the store is set up in memory instead of on disk.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SkillSpringModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("CRITICAL: Core Data failed to load. The model file might be missing from the target. Error: \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
