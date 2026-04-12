import Foundation
import StoreKit
import Combine

// MARK: - StoreKitService
// Advanced iOS Feature 3: StoreKit 2 In-App Purchases
//
// SIMULATOR TESTING:
// 1. In Xcode: Edit Scheme → Run → Options → StoreKit Configuration → SkillSpryng.storekit
// 2. Build and run on Simulator
// 3. Tap Premium or Wallet → products will load and show sandbox prices
// 4. Complete a purchase — no real money is charged in sandbox
// 5. To reset: Debug → StoreKit → Manage Transactions → Delete All
// 6. Force-quit and relaunch to verify restorePurchases / checkSubscriptionStatus

@MainActor
class StoreKitService: ObservableObject {

    static let shared = StoreKitService()

    @Published var products: [Product] = []
    @Published var proMonthly: Product?
    @Published var proYearly: Product?
    @Published var creditPacks: [Product] = []
    @Published var isPurchasing: Bool = false
    @Published var purchaseError: String?
    @Published var isUserPro: Bool = false
    @Published var creditsToast: String?

    private var transactionListener: Task<Void, Error>?

    private init() {
        // Start transaction listener immediately on init.
        // This catches any pending or interrupted purchases (e.g. parent approval flows).
        transactionListener = listenForTransactions()

        // Check subscription status from persistent entitlements
        Task {
            await checkSubscriptionStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - FUNCTION 1: loadProducts
    func loadProducts() async {
        do {
            let productIds = Set([
                "com.skillspryng.pro.monthly",
                "com.skillspryng.pro.yearly",
                "com.skillspryng.credits.100",
                "com.skillspryng.credits.500",
                "com.skillspryng.credits.1200"
            ])

            let fetched = try await Product.products(for: productIds)
            self.products = fetched

            self.proMonthly = fetched.first(where: { $0.id.contains("monthly") })
            self.proYearly = fetched.first(where: { $0.id.contains("yearly") })
            self.creditPacks = fetched
                .filter { $0.id.contains("credits") }
                .sorted { $0.price < $1.price }

            if fetched.isEmpty {
                print("[StoreKit] ⚠️ No products returned. Check scheme StoreKit config or product IDs.")
                purchaseError = "StoreKit config not linked. In Edit Scheme → Run → Options → StoreKit Configuration → select LocalStore."
            } else {
                print("[StoreKit] ✅ Loaded \(fetched.count) products.")
            }
        } catch {
            print("[StoreKit] ❌ Failed to load products: \(error)")
            purchaseError = "Could not load products. Please try again."
        }
    }

    // MARK: - FUNCTION 2: purchase
    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await handleSuccessfulPurchase(transaction: transaction, productId: product.id)
                await transaction.finish()
                return true

            case .userCancelled:
                return false

            case .pending:
                purchaseError = "Purchase pending approval. You will be notified when complete."
                return false

            default:
                return false
            }
        } catch StoreKitError.notEntitled {
            purchaseError = "Purchase could not be verified."
            return false
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
    }

    // MARK: - FUNCTION 3: checkVerified (PRIVATE)
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - FUNCTION 4: handleSuccessfulPurchase (PRIVATE)
    private func handleSuccessfulPurchase(transaction: Transaction, productId: String) async {
        if productId.contains("pro") {
            isUserPro = true

            // Sync to Firestore
            await FirebaseManager.shared.updateUserPro(
                isPremium: true,
                expiryDate: transaction.expirationDate
            )

            // Persist locally
            UserDefaults.standard.set(true, forKey: "skillspryng.isPremium")
            PersistenceService.shared.updateLocalUserPro(isPremium: true)

            // Welcome notification
            NotificationManager.shared.schedulePremiumWelcomeNotification()

            print("[StoreKit] ✅ Pro subscription activated: \(productId)")

        } else if productId.contains("credits") {
            let credits = creditsForProduct(productId)

            // Sync to Firestore
            await FirebaseManager.shared.addCredits(amount: credits)

            // Update local mock balance
            MockDataProvider.shared.currentUser.walletBalance += credits

            // Show toast
            creditsToast = "+\(credits) Credits added!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.creditsToast = nil
            }

            print("[StoreKit] ✅ Credits purchased: +\(credits)")
        }
    }

    // MARK: - FUNCTION 5: creditsForProduct (PRIVATE)
    private func creditsForProduct(_ productId: String) -> Int {
        if productId.contains("credits.100") { return 100 }
        if productId.contains("credits.500") { return 500 }
        if productId.contains("credits.1200") { return 1200 }
        return 0
    }

    // MARK: - FUNCTION 6: restorePurchases
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                await handleSuccessfulPurchase(
                    transaction: transaction,
                    productId: transaction.productID
                )
            }
        }
        creditsToast = "Purchases restored successfully"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.creditsToast = nil
        }
    }

    // MARK: - FUNCTION 7: listenForTransactions (PRIVATE)
    // Handles interrupted purchases and subscription renewals in the background
    private func listenForTransactions() -> Task<Void, Error> {
        Task(priority: .background) {
            for await result in Transaction.updates {
                if let transaction = try? checkVerified(result) {
                    await handleSuccessfulPurchase(
                        transaction: transaction,
                        productId: transaction.productID
                    )
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - FUNCTION 8: checkSubscriptionStatus
    // Called on app launch to silently verify and restore Pro status
    func checkSubscriptionStatus() async {
        var foundPro = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID.contains("pro") {
                    isUserPro = true
                    foundPro = true
                    return
                }
            }
        }
        if !foundPro {
            isUserPro = false
            // Sync revocation to Firestore if status changed
            if UserDefaults.standard.bool(forKey: "skillspryng.isPremium") {
                await FirebaseManager.shared.updateUserPro(isPremium: false, expiryDate: nil)
                UserDefaults.standard.set(false, forKey: "skillspryng.isPremium")
                PersistenceService.shared.updateLocalUserPro(isPremium: false)
            }
        }
    }
}
