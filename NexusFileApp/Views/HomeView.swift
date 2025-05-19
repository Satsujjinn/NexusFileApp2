//
//  HomeView.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var fm = FileManagerService()
    @State private var showingNew = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(fm.items.filter(\.isDirectory)) { item in
                        NavigationLink(
                            destination: FolderView(
                                service: fm.navigate(to: item),
                                title: item.name
                            )
                        ) {
                            CategoryCard(name: item.name)
                        }
                    }
                }
                .padding()
            }
            .background(Color.nexusBackground.ignoresSafeArea())
            .navigationTitle("Kategorieë")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { showingNew = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                    Button("Logout") {
                        // TODO: add your logout logic
                    }
                }
            }
            .sheet(isPresented: $showingNew) {
                NewFolderSheet(
                    title: "Nuwe Kategorieë",
                    placeholder: "Naam"
                ) { name in
                    fm.createFolder(named: name)
                }
            }
            .onAppear { fm.loadItems() }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
