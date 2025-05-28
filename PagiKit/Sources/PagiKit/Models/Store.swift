import StoreKit

extension Product {
    static let lifetimeId = "pagi.lifetime.2025"
}

fileprivate let productIds = [Product.lifetimeId]

@MainActor
public final class Store: ObservableObject {
    
    private var updates: Task<Void, Never>? = nil
    
    /// User unlocked all features
    @Published public var isEntitled = false
    /// The entitlement the user unlocked all features with
    @Published public var entitledTransaction: Transaction?
    @Published public var hasCheckedForEntitlements = false
    
    public init() {
        updates = newTransactionListenerTask()
    }
    
    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
    }
    
    public var isUnlocked: Bool { isLifetimeActive || isSubscriptionActive }
    
    var isLegacyVersion: Bool {
        isEntitled == true && entitledTransaction == nil
    }
    
    public var isLifetimeActive: Bool {
        entitledTransaction?.productType == .nonConsumable || isLegacyVersion
    }
    
    public var isSubscriptionActive: Bool {
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
    
    public func fetchProducts() async throws -> [Product] {
        try await Product.products(for: productIds)
    }
    
    public func purchase(product: Product) async throws {
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
    
    public func handle(transaction verificationResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verificationResult else {
            return
        }
        
        isEntitled = true
        entitledTransaction = transaction
        await transaction.finish()
    }
    
    public func refreshPurchasedProducts() async {
        do {
            let shared = try await AppTransaction.shared
            if case .verified(let appTransaction) = shared {
                let isSandbox = [AppStore.Environment.sandbox, .xcode].contains(appTransaction.environment)
                let didUserPurchaseLegacyLifetime = Store.didUserPurchaseLegacyLifetime(originalAppVersion: appTransaction.originalAppVersion)
                
                if !isSandbox && didUserPurchaseLegacyLifetime {
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

extension Store {
    
    static func didUserPurchaseLegacyLifetime(originalAppVersion: String) -> Bool {
        let newBusinessModelMajorVersion = "2"
        let versionComponents = originalAppVersion.split(separator: ".")
        let originalMajorVersion = versionComponents[0]
        
        return originalMajorVersion < newBusinessModelMajorVersion
    }
    
}
