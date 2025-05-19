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
                Section(header: Text("Hernoem")) {
                    TextField("Nuwe naam", text: $newName)
                }
            }
            .navigationTitle("Hernoem")
            .navigationBarItems(
                leading: Button("Kanselleer") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Stoor") {
                    onRename(newName.trimmingCharacters(in: .whitespaces))
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
}
