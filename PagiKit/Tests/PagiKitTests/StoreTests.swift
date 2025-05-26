import Testing
@testable import PagiKit

fileprivate let lifetimeAppVersionsiOS = ["1.0", "1.1", "1.1.1", "1.1.2", "1.1.3", "1.1.4", "1.2", "1.2.1", "1.2.2", "1.2.3"]
fileprivate let lifetimeAppVersionsmacOS = ["1.5.2", "1.5.3", "1.6"]

struct StoreTests {
    
    @Test("iOS: Did user purchase legacy lifetime app version", arguments: lifetimeAppVersionsiOS)
    func didUserPurchaseLegacyLifetimeiOS(_ version: String) async throws {
        await #expect(Store.didUserPurchaseLegacyLifetime(originalAppVersion: version) == true)
    }
    
    @Test("macOS: Did user purchase legacy lifetime app version", arguments: lifetimeAppVersionsmacOS)
    func didUserPurchaseLegacyLifetimemacOS(_ version: String) async throws {
        await #expect(Store.didUserPurchaseLegacyLifetime(originalAppVersion: version) == true)
    }
    
    @Test("User did not purchase legacy lifetime version", arguments: ["2.0", "2.1", "2.1.3", "3"])
    func noLegacyLifetimeVersion(_ version: String) async throws {
        await #expect(Store.didUserPurchaseLegacyLifetime(originalAppVersion: version) == false)
    }
    
}
