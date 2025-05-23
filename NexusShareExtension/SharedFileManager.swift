//
//  SharedFileManager.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import Foundation

struct SharedFileManager {
    static let appGroupID = "group.com.yourcompany.NexusFileApp"

    static var containerURL: URL {
        FileManager.default
          .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
    }

    static var documentsURL: URL {
        containerURL.appendingPathComponent("Documents", isDirectory: true)
    }

    static func save(file url: URL, to subfolder: String, named name: String) throws {
        let folderURL = documentsURL.appendingPathComponent(subfolder, isDirectory: true)
        try FileManager.default
          .createDirectory(at: folderURL, withIntermediateDirectories: true)
        let destURL = folderURL.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: destURL.path) {
            try FileManager.default.removeItem(at: destURL)
        }
        try FileManager.default.copyItem(at: url, to: destURL)
    }

    /// List all subfolders at an optional relative path
    static func listFolders(at subpath: String = "") -> [String] {
        let url = subpath.isEmpty
            ? documentsURL
            : documentsURL.appendingPathComponent(subpath, isDirectory: true)
        guard let contents = try? FileManager.default
                .contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: [.skipsHiddenFiles]
                ) else { return [] }
        return contents
          .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false }
          .map { $0.lastPathComponent }
          .sorted()
    }
}
