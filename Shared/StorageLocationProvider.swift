import Foundation

protocol StorageLocationProvider {
    var storageURL: URL? { get }
}

struct RealStorageLocationProvider: StorageLocationProvider {
    var storageURL: URL? {
        let containerURL: URL?
        
        if let iCloudContainerURL = FileManager.default.iCloudContainerURL {
            containerURL = iCloudContainerURL
        } else {
            containerURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
        
        return containerURL
    }
}

struct MockStorageLocationProvider: StorageLocationProvider {
    var storageURL: URL? {
        FileManager.default.temporaryDirectory
    }
}
