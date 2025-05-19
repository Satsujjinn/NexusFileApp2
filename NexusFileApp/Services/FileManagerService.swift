//
//  FileManagerService.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

//  FileManagerService.swift
import Foundation

class FileManagerService: ObservableObject {
    @Published var items: [DirectoryItem] = []

    private let fileManager = FileManager.default
    private let documentsURL: URL
    private(set) var currentURL: URL

    init(startingAt url: URL? = nil) {
        // base Documents directory
        let docs = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        self.documentsURL = docs
        self.currentURL = url ?? docs
        loadItems()
    }

    /// Load & sort both folders and files
    func loadItems() {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        guard let urls = try? fileManager
                .contentsOfDirectory(
                  at: currentURL,
                  includingPropertiesForKeys: keys,
                  options: [.skipsHiddenFiles]
                ) else {
            items = []
            return
        }

        items = urls.map { DirectoryItem(id: $0) }
            .sorted {
                if $0.isDirectory && !$1.isDirectory { return true }
                if !$0.isDirectory && $1.isDirectory { return false }
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
    }

    /// Create a brand-new service rooted at this subfolder
    func navigate(to item: DirectoryItem) -> FileManagerService {
        return FileManagerService(startingAt: item.id)
    }

    /// Make a new folder
    func createFolder(named name: String) {
        let newURL = currentURL.appendingPathComponent(name, isDirectory: true)
        do {
            try fileManager.createDirectory(
              at: newURL,
              withIntermediateDirectories: false)
            loadItems()
        } catch {
            print("Error creating folder:", error)
        }
    }

    /// Copy in a PDF/XLSX from the picker
    func importFile(from url: URL) {
        let dest = currentURL.appendingPathComponent(url.lastPathComponent)
        do {
            if fileManager.fileExists(atPath: dest.path) {
                try fileManager.removeItem(at: dest)
            }
            try fileManager.copyItem(at: url, to: dest)
            loadItems()
        } catch {
            print("Error importing file:", error)
        }
    }

    /// Delete any file or folder
    func delete(item: DirectoryItem) {
        do {
            try fileManager.removeItem(at: item.id)
            loadItems()
        } catch {
            print("Error deleting item:", error)
        }
    }

    /// Rename by moving to a new URL
    func rename(item: DirectoryItem, to newName: String) {
        let newURL = item.id
            .deletingLastPathComponent()
            .appendingPathComponent(newName,
                                   isDirectory: item.isDirectory)
        do {
            try fileManager.moveItem(at: item.id, to: newURL)
            loadItems()
        } catch {
            print("Error renaming item:", error)
        }
    }
}
