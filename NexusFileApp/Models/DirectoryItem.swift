import Foundation

struct DirectoryItem: Identifiable {
  let id: URL
  var name: String { id.lastPathComponent }
  var isDirectory: Bool {
    (try? id.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
  }
}
