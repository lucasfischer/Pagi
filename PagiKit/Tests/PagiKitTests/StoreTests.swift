import Testing
import StoreKit
@testable import PagiKit

fileprivate let lifetimeAppVersionsiOS = ["1.0", "1.1", "1.1.1", "1.1.2", "1.1.3", "1.1.4", "1.2", "1.2.1", "1.2.2", "1.2.3"]
fileprivate let lifetimeAppVersionsmacOS = ["1.5.2", "1.5.3", "1.6"]
fileprivate let inAppPurchaseAppVersions = ["2", "2.0", "2.0.1", "2.1.3", "3"]

struct StoreTests {
    
    @Test("iOS: Did user purchase legacy lifetime app version", arguments: lifetimeAppVersionsiOS)
    func didUserPurchaseLegacyLifetimeiOS(_ version: String) async throws {
        let isLegacyPurchase = await Store.didUserPurchaseLegacyLifetime(
            originalAppVersion: version,
            environment: .production
        )
        
        #expect(isLegacyPurchase)
    }
    
    @Test("macOS: Did user purchase legacy lifetime app version", arguments: lifetimeAppVersionsmacOS)
    func didUserPurchaseLegacyLifetimemacOS(_ version: String) async throws {
        let isLegacyPurchase = await Store.didUserPurchaseLegacyLifetime(
            originalAppVersion: version,
            environment: .production
        )
        
        #expect(isLegacyPurchase)
    }
    
    @Test("User did not purchase legacy lifetime version", arguments: inAppPurchaseAppVersions)
    func noLegacyLifetimeVersion(_ version: String) async throws {
        let isLegacyPurchase = await Store.didUserPurchaseLegacyLifetime(
            originalAppVersion: version,
            environment: .production
        )
        
        #expect(!isLegacyPurchase)
    }
    
    @Test("User did not purchase legacy lifetime version in Sandbox", arguments: ["1", "1.0"], [AppStore.Environment.sandbox, .xcode])
    func noLegacyLifetimeVersionInSandbox(_ version: String, environment: AppStore.Environment) async throws {
        let isLegacyPurchase = await Store.didUserPurchaseLegacyLifetime(
            originalAppVersion: version,
            environment: environment
        )
        
        #expect(!isLegacyPurchase)
    }
    
}
