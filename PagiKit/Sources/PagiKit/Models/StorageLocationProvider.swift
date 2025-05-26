import Foundation

public protocol StorageLocationProvider {
    var storageURL: URL? { get }
}

public struct RealStorageLocationProvider: StorageLocationProvider {
    
    public init() {}
    
    public var storageURL: URL? {
        let containerURL: URL?
        
        if let iCloudContainerURL = FileManager.default.iCloudContainerURL {
            containerURL = iCloudContainerURL
        } else {
            containerURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
        
        return containerURL
    }
}

public struct MockStorageLocationProvider: StorageLocationProvider {
    
    public init() {}
    
    public var storageURL: URL? {
        FileManager.default.temporaryDirectory
    }
}
