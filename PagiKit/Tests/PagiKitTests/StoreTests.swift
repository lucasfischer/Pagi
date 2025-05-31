import Testing
import StoreKit
@testable import PagiKit

struct StoreTests {
    
    @Test("Return true if user did purchase legacy lifetime app version")
    func didPurchaseLegacyVersion() async throws {
        let isLegacyPurchase = await Store.didUserPurchaseLegacyLifetime(
            originalPurchaseDate: Date(timeIntervalSince1970: 1716987600), // Wed May 29 2024 13:00:00 GMT+0000
            environment: .production
        )
        #expect(isLegacyPurchase)
    }
    
    @Test("Return false if user did not purchase legacy lifetime app version")
    func didPurchaseNow() async {
        let isLegacyPurchase = await Store.didUserPurchaseLegacyLifetime(
            originalPurchaseDate: Date(timeIntervalSince1970: 1748696400), // Sat May 31 2025 13:00:00 GMT+0000
            environment: .production
        )
        #expect(!isLegacyPurchase)
    }
    
    @Test("Return false if environment is sandbox", arguments: [AppStore.Environment.sandbox, .xcode])
    func isSandboxEnvironment(_ environment: AppStore.Environment) async {
        let isLegacyPurchase = await Store.didUserPurchaseLegacyLifetime(
            originalPurchaseDate: Date(timeIntervalSince1970: 1375340400), // 2013-08-01 12 AM PDT
            environment: environment
        )
        #expect(!isLegacyPurchase)
    }
    
}
