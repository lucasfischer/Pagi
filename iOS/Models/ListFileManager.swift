import Foundation

@MainActor
protocol ListFileManager {
    func loadFiles() async throws -> [File]
    func remove(file: File) async throws
}

final class RealListFileManager: ListFileManager {
    
    let storageLocationProvider: StorageLocationProvider
    
    init(storageLocationProvider: StorageLocationProvider) {
        self.storageLocationProvider = storageLocationProvider
    }
    
    func loadFiles() async throws -> [File] {
        guard let containerURL = storageLocationProvider.storageURL else {
            return []
        }
        
        let urls = try await CloudStorage.shared.listFiles(in: containerURL)
        var files = [File]()
        for url in urls.sorted(by: { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedDescending }) {
            let text = "" // try await CloudStorage.shared.readFromCloud(fileURL: url)
            files.append(
                File(url: url, text: text)
            )
        }
        return files
    }
    
    func remove(file: File) async throws {
        try await CloudStorage.shared.delete(file.url)
    }
    
}

final class MockListFileManager: ListFileManager {
    
    let storageLocationProvider: StorageLocationProvider
    
    init(storageLocationProvider: StorageLocationProvider) {
        self.storageLocationProvider = storageLocationProvider
    }
    
    func loadFiles() async throws -> [File] {
        return Array(1...100).map { i in
            let date = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            return File(url: storageLocationProvider.storageURL!.appendingPathComponent(date.formatted(.iso8601.year().month().day()), conformingTo: .plainText), text: "Hello, World!")
        }
    }
    
    func remove(file: File) async throws {
        
    }
    
}
