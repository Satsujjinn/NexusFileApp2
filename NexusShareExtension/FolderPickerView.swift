//
//  FolderPickerView.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI

struct FolderPickerView: View {
    /// The path relative to the app group Documents folder
    let subpath: String
    /// Called when the user taps “Save in …”
    var onSelect: (String) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Folders") {
                    // List all subfolders at this level
                    ForEach(SharedFileManager.listFolders(at: subpath), id: \.self) { name in
                        // Compute the next subpath
                        let nextPath = subpath.isEmpty
                            ? name
                            : "\(subpath)/\(name)"

                        // Drill down
                        NavigationLink {
                            FolderPickerView(subpath: nextPath, onSelect: onSelect)
                        } label: {
                            Text(name)
                        }
                    }
                }

                // “Save here” button when you’re not at the root
                if !subpath.isEmpty {
                    Section {
                        Button("Save in \"\(subpath)\"") {
                            onSelect(subpath)
                        }
                    }
                }
            }
            .navigationTitle(subpath.isEmpty ? "Choose Folder" : subpath)
        }
    }
}
