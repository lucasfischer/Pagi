import Foundation

public extension FileManager {
    var iCloudContainerURL: URL? {
        url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
    }
}
