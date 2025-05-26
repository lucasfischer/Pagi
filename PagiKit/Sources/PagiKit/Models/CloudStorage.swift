import Foundation
import SwiftUI

public protocol FileStorage {
    func save(_: URL, withContent: String) async throws
    func read(from: URL) async throws -> String
    func listFiles(in: URL) async throws -> [URL]
    func delete(_: URL) async throws
}

public actor CloudStorage: FileStorage {
    public static let shared = CloudStorage()
    
    private let fileManager = FileManager.default
    private let fileCoordinator = NSFileCoordinator()
    
    // Save a file to iCloud Drive
    public func save(_ url: URL, withContent: String) async throws {
        // Use file coordinator for writing
        var error: NSError?
        fileCoordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &error) { url in
            do {
                try withContent.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                print("Error writing file: \(error)")
            }
        }
        
        if let error {
            throw error
        }
    }
    
    // Read a file from iCloud Drive
    public func read(from url: URL) async throws -> String {
        // Check if file exists
        guard fileManager.fileExists(atPath: url.path) else {
            throw CloudError.fileNotFound
        }
        
        // Use file coordinator for reading
        var error: NSError?
        var content: String?
        
        fileCoordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &error) { url in
            do {
                content = try String(contentsOf: url, encoding: .utf8)
            } catch {
                print("Error reading file: \(error)")
            }
        }
        
        if let error {
            throw error
        }
        
        guard let fileContent = content else {
            throw CloudError.readFailed
        }
        
        return fileContent
    }
    
    // List all files in the iCloud container
    public func listFiles(in url: URL) async throws -> [URL] {
        var error: NSError?
        var files: [URL] = []
        
        fileCoordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &error) { url in
            do {
                files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            } catch {
                print("Error listing files: \(error)")
            }
        }
        
        if let error {
            throw error
        }
        
        return files
    }
    
    // Delete a file from iCloud Drive
    public func delete(_ url: URL) async throws {
        // Check if file exists
        guard fileManager.fileExists(atPath: url.path) else {
            throw CloudError.fileNotFound
        }
        
        // Use file coordinator for deleting
        var error: NSError?
        
        fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: &error) { url in
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Error deleting file: \(error)")
            }
        }
        
        if let error {
            throw error
        }
    }
}

// Custom error enum for cloud operations
public enum CloudError: Error {
    case containerNotFound
    case fileNotFound
    case saveFailed
    case readFailed
    case deleteFailed
}
