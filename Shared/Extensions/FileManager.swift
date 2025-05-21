import Foundation

extension FileManager {
    var iCloudContainerURL: URL? {
        url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
    }
}
