//
//  ShareContentView.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI

struct ShareContentView: View {
    let sharedURL: URL
    var onSave: (String, String) -> Void

    @State private var chosenFolder = ""
    @State private var fileName = ""

    var body: some View {
        NavigationStack {
            FolderPickerView(subpath: "") { folder in
                chosenFolder = folder
                fileName = sharedURL.lastPathComponent
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Maak Submap") {
                        // TODO: present a sheet to create a new subfolder here
                    }
                    .disabled(chosenFolder.isEmpty)
                }
            }

            // Once a folder is chosen, show name & Save
            if !chosenFolder.isEmpty {
                Form {
                    Section(header: Text("Gids: \(chosenFolder)")) { }
                    Section(header: Text("Naam")) {
                        TextField(sharedURL.lastPathComponent, text: $fileName)
                    }
                    Section {
                        Button("Stoor Lêer") {
                            onSave(chosenFolder,
                                   fileName.isEmpty
                                     ? sharedURL.lastPathComponent
                                     : fileName)
                        }
                    }
                }
                .navigationTitle("Baskanselleer")
            }
        }
    }
}
