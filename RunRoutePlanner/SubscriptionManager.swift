import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var isSubscribed: Bool = false
    @Published var products: [Product] = []
    @Published var purchaseError: String?

    private let productID = AppConstants.Subscription.productID
    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // Load available subscription products
    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: [productID])
            products = storeProducts
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // Purchase subscription
    func purchase() async throws {
        guard let product = products.first else {
            throw SubscriptionError.productNotFound
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateSubscriptionStatus()

            case .userCancelled:
                purchaseError = "Purchase cancelled"

            case .pending:
                purchaseError = "Purchase pending approval"

            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
            throw error
        }
    }

    // Restore purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            purchaseError = "Failed to restore purchases"
        }
    }

    // Check current subscription status
    func updateSubscriptionStatus() async {
        var isActive = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if subscription is active
                if transaction.productID == productID {
                    isActive = true
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }

        isSubscribed = isActive
    }

    // Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }

    // Verify transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum SubscriptionError: Error {
    case productNotFound
    case failedVerification

    var localizedDescription: String {
        switch self {
        case .productNotFound:
            return "Subscription product not found"
        case .failedVerification:
            return "Transaction verification failed"
        }
    }
}
