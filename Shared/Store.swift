import StoreKit

extension Product {
    static let lifetimeId = "pagi.lifetime.2025"
}

fileprivate let productIds = [Product.lifetimeId]
fileprivate let lifetimeAppVersions = ["1.0", "1.1", "1.1.1", "1.1.2", "1.1.3", "1.1.4", "1.2", "1.2.1", "1.2.2", "1.2.3"]

@MainActor
final class Store: ObservableObject {
    
    private var updates: Task<Void, Never>? = nil
    
    /// User unlocked all features
    @Published var isEntitled = false
    /// The entitlement the user unlocked all features with
    @Published var entitledTransaction: Transaction?
    @Published var hasCheckedForEntitlements = false
    
    init() {
        updates = newTransactionListenerTask()
    }
    
    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
    }
    
    var isUnlocked: Bool { isLifetimeActive || isSubscriptionActive }
    
    var isLegacyVersion: Bool {
        isEntitled == true && entitledTransaction == nil
    }
    
    var isLifetimeActive: Bool {
        entitledTransaction?.productType == .nonConsumable || isLegacyVersion
    }
    
    var isSubscriptionActive: Bool {
        entitledTransaction?.productType == .autoRenewable
    }
    
    var manageSubscriptionURL: URL {
        URL(string: "itms-apps://apps.apple.com/account/subscriptions")!
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                self.handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) {
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }
        
        if let _ = transaction.revocationDate {
            isEntitled = false
            // Remove access to the product identified by transaction.productID.
            // Transaction.revocationReason provides details about
            // the revoked transaction.
        } else if let expirationDate = transaction.expirationDate,
                  expirationDate < Date() {
            // Do nothing, this subscription is expired.
            return
        } else if transaction.isUpgraded {
            // Do nothing, there is an active transaction
            // for a higher level of service.
            return
        } else {
            // Provide access to the product identified by
            // transaction.productID.
            isEntitled = true
            entitledTransaction = transaction
        }
    }
    
    func fetchProducts() async throws -> [Product] {
        try await Product.products(for: productIds)
    }
    
    func purchase(product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
            case .success(let transaction):
                await handle(transaction: transaction)
            case .pending, .userCancelled:
                break
            @unknown default:
                break
        }
    }
    
    func handle(transaction verificationResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verificationResult else {
            return
        }
        
        isEntitled = true
        entitledTransaction = transaction
        await transaction.finish()
    }
    
    func refreshPurchasedProducts() async {
        do {
            let shared = try await AppTransaction.shared
            if case .verified(let appTransaction) = shared {
                if lifetimeAppVersions.contains(appTransaction.originalAppVersion) {
                    isEntitled = true
                    return
                }
            }
        }
        catch {
            print(error)
        }
        
        var isEntitled = false
        var entitledTransaction: Transaction?
        // Iterate through the user's purchased products.
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
                case .verified(let transaction):
                    isEntitled = true
                    entitledTransaction = transaction
                case .unverified(_, let verificationError):
                    print(verificationError)
            }
        }
        
        self.isEntitled = isEntitled
        self.entitledTransaction = entitledTransaction
        self.hasCheckedForEntitlements = true
    }
    
}
