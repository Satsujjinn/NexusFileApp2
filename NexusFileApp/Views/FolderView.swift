//
//  FolderView.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct FolderView: View {
    @ObservedObject var service: FileManagerService
    let title: String

    @State private var showingNewFolder = false
    @State private var showingImporter = false
    @State private var shareURL: URL?
    @State private var renameTarget: DirectoryItem?
    @State private var sortMode: SortMode = .name
    @State private var searchText = ""

    enum SortMode { case name, date }

    var filteredItems: [DirectoryItem] {
        let base = searchText.isEmpty
            ? service.items
            : service.items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        switch sortMode {
        case .name:
            return base.sorted {
                if $0.isDirectory && !$1.isDirectory { return true }
                if !$0.isDirectory && $1.isDirectory { return false }
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
        case .date:
            return base.sorted {
                let d0 = (try? $0.id.resourceValues(forKeys: [.contentModificationDateKey])
                                .contentModificationDate) ?? Date.distantPast
                let d1 = (try? $1.id.resourceValues(forKeys: [.contentModificationDateKey])
                                .contentModificationDate) ?? Date.distantPast
                return d0 > d1
            }
        }
    }

    var body: some View {
        List {
            ForEach(filteredItems) { item in
                row(for: item)
            }
            .onDelete { idxs in
                idxs.forEach { service.delete(item: filteredItems[$0]) }
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
                    Divider()
                    Picker("Sorteer op", selection: $sortMode) {
                        Label("Naam", systemImage: "textformat").tag(SortMode.name)
                        Label("Datum", systemImage: "calendar").tag(SortMode.date)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 22))
                }
            }
        }
        .sheet(isPresented: $showingNewFolder) {
            NewFolderSheet(title: "Nuwe Gids", placeholder: "Naam") {
                service.createFolder(named: $0)
            }
        }
        .fileImporter(isPresented: $showingImporter,
                      allowedContentTypes: [.pdf, .spreadsheet],
                      allowsMultipleSelection: true) { result in
            if case .success(let urls) = result {
                urls.forEach { service.importFile(from: $0) }
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
                destination: FolderView(service: service.navigate(to: item),
                                        title: item.name)
            ) {
                Label(item.name, systemImage: "folder.fill")
            }
            .contextMenu {
                Button("Hernoem") { renameTarget = item }
                Button("Verwyder", role: .destructive) {
                    service.delete(item: item)
                }
            }
        } else {
            HStack {
                Label(item.name, systemImage: "doc.fill")
                Spacer()
                Button { shareURL = item.id } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .contextMenu {
                Button("Open") { shareURL = item.id }
                Button("Share") { shareURL = item.id }
                if item.id.pathExtension.lowercased().contains("xls") {
                    Button("Stuur as PDF") {
                        // stub: no-op for now
                    }
                }
                Button("Duplicate") { service.duplicate(item: item) }
                Button("Hernoem") { renameTarget = item }
                Button("Verwyder", role: .destructive) {
                    service.delete(item: item)
                }
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    service.delete(item: item)
                } label: {
                    Label("Verwyder", systemImage: "trash")
                }
                Button {
                    renameTarget = item
                } label: {
                    Label("Hernoem", systemImage: "pencil")
                }
                .tint(.orange)
            }
        }
    }
}
