//
//  FileManagerService.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import Foundation

class FileManagerService: ObservableObject {
    @Published var items: [DirectoryItem] = []

    private let fileManager = FileManager.default
    private let documentsURL: URL
    private(set) var currentURL: URL

    /// Your six required top-level categories
    private let defaultCategories = [
        "Spuitprogramme",
        "MRL",
        "Etikette",
        "Kalibrasies",
        "Aanbevelings",
        "Gewas Inligting"
    ]

    init(startingAt url: URL? = nil) {
        // Base Documents directory
        let docs = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        self.documentsURL = docs
        self.currentURL = url ?? docs

        // Seed your six main folders
        ensureDefaultCategories()
        // Then load currentURL items
        loadItems()
    }

    private func ensureDefaultCategories() {
        for name in defaultCategories {
            let folderURL = documentsURL.appendingPathComponent(name, isDirectory: true)
            var isDir: ObjCBool = false
            if !fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDir) {
                try? fileManager.createDirectory(
                    at: folderURL,
                    withIntermediateDirectories: false
                )
            }
        }
    }

    func loadItems() {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        guard let urls = try? fileManager.contentsOfDirectory(
                at: currentURL,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles]
        ) else {
            items = []
            return
        }

        items = urls.map(DirectoryItem.init)
            .sorted {
                // directories first
                if $0.isDirectory && !$1.isDirectory { return true }
                if !$0.isDirectory && $1.isDirectory { return false }
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
    }

    func navigate(to item: DirectoryItem) -> FileManagerService {
        FileManagerService(startingAt: item.id)
    }

    func createFolder(named name: String) {
        let newURL = currentURL.appendingPathComponent(name, isDirectory: true)
        try? fileManager.createDirectory(at: newURL,
                                         withIntermediateDirectories: false)
        loadItems()
    }

    func importFile(from url: URL) {
        let dest = currentURL.appendingPathComponent(url.lastPathComponent)
        if fileManager.fileExists(atPath: dest.path) {
            try? fileManager.removeItem(at: dest)
        }
        try? fileManager.copyItem(at: url, to: dest)
        loadItems()
    }

    func delete(item: DirectoryItem) {
        try? fileManager.removeItem(at: item.id)
        loadItems()
    }

    func rename(item: DirectoryItem, to newName: String) {
        let newURL = item.id
            .deletingLastPathComponent()
            .appendingPathComponent(newName, isDirectory: item.isDirectory)
        try? fileManager.moveItem(at: item.id, to: newURL)
        loadItems()
    }

    /// Duplicate by appending “ copy” to filename before the extension
    func duplicate(item: DirectoryItem) {
        let original = item.id
        let base = original.deletingPathExtension().lastPathComponent
        let ext  = original.pathExtension
        let copyName = "\(base) copy.\(ext)"
        let dest = currentURL.appendingPathComponent(copyName)
        try? fileManager.copyItem(at: original, to: dest)
        loadItems()
    }
}
