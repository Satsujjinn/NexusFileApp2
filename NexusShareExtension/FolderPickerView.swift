//
//  FolderPickerView.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI

struct FolderPickerView: View {
    let subpath: String
    var onSelect: (String) -> Void

    var body: some View {
        List {
            ForEach(SharedFileManager.listFolders(at: subpath), id: \.self) { name in
                let nextPath = subpath.isEmpty ? name : "\(subpath)/\(name)"
                NavigationLink(name, value: nextPath)
            }
            if !subpath.isEmpty {
                Section {
                    Button("Stoor in “\(subpath)”") {
                        onSelect(subpath)
                    }
                }
            }
        }
        .navigationTitle(subpath.isEmpty ? "Kies Kategorieë" : subpath)
        .navigationDestination(for: String.self) { next in
            FolderPickerView(subpath: next, onSelect: onSelect)
        }
    }[/jb  vnm/
}
