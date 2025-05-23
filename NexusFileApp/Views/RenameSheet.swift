//
//  RenameSheet.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI

struct RenameSheet: View {
    let item: DirectoryItem
    var onRename: (String) -> Void

    @Environment(\.presentationMode) private var presentationMode
    @State private var newName: String

    init(item: DirectoryItem, onRename: @escaping (String) -> Void) {
        self.item = item
        self.onRename = onRename
        _newName = State(initialValue: item.name)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rename")) {
                    TextField("New name", text: $newName)
                }
            }
            .navigationTitle("Rename")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    onRename(newName.trimmingCharacters(in: .whitespaces))
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
}
