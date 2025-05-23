//
//  NewFolderSheet.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI

struct NewFolderSheet: View {
    let title: String
    let placeholder: String
    var onCreate: (String) -> Void

    @Environment(\.presentationMode) private var presentationMode
    @State private var name = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(title)) {
                    TextField(placeholder, text: $name)
                }
            }
            .navigationTitle(title)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Create") {
                    onCreate(name.trimmingCharacters(in: .whitespaces))
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
}
