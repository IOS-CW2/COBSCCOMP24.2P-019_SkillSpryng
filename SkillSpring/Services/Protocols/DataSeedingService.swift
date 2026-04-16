import Foundation

protocol DataSeedingService: Sendable {
    func seedAll() async
}
