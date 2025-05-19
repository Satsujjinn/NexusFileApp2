//
//  NexusFileAppApp.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI

@main
struct NexusFileAppApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .accentColor(.nexusGreen)
                .background(Color.nexusBackground.ignoresSafeArea())
        }
    }
}
