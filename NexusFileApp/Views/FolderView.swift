//
//  FolderView.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI
import UniformTypeIdentifiers

struct FolderView: View {
    @ObservedObject var service: FileManagerService
    let title: String

    @State private var showingNewFolder = false
    @State private var showingImporter = false
    @State private var shareURL: URL?
    @State private var renameTarget: DirectoryItem?
    @State private var searchText = ""

    // filter by search
    var filteredItems: [DirectoryItem] {
        searchText.isEmpty
            ? service.items
            : service.items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
    }

    var body: some View {
        List {
            ForEach(filteredItems) { item in
                row(for: item)
                    .contextMenu {
                        Button("Hernoem") { renameTarget = item }
                        Button("Verwyder", role: .destructive) {
                            service.delete(item: item)
                        }
                    }
            }
            .onDelete { idxs in
                idxs.forEach { idx in
                    let item = filteredItems[idx]
                    service.delete(item: item)
                }
            }
        }
        .searchable(text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Nuwe Gids") { showingNewFolder = true }
                    Button("Laai Lêer") { showingImporter = true }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            }
        }
        .sheet(isPresented: $showingNewFolder) {
            NewFolderSheet(
                title: "Nuwe Gids",
                placeholder: "Naam"
            ) { name in
                service.createFolder(named: name)
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.pdf, .spreadsheet],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                urls.forEach { service.importFile(from: $0) }
            case .failure(let err):
                print("Import error:", err)
            }
        }
        .sheet(item: $shareURL) { url in
            ShareSheet(activityItems: [url])
        }
        .sheet(item: $renameTarget) { item in
            RenameSheet(item: item) { newName in
                service.rename(item: item, to: newName)
            }
        }
        .onAppear { service.loadItems() }
    }

    @ViewBuilder
    private func row(for item: DirectoryItem) -> some View {
        if item.isDirectory {
            NavigationLink(
                destination: FolderView(
                    service: service.navigate(to: item),
                    title: item.name
                )
            ) {
                Label(item.name, systemImage: "folder.fill")
            }
        } else {
            HStack {
                Label(item.name, systemImage: "doc.fill")
                Spacer()
                Button { shareURL = item.id } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}
