//
//  ShareSheet.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context)
      -> UIActivityViewController {
        UIActivityViewController(
          activityItems: activityItems,
          applicationActivities: nil
        )
    }

    func updateUIViewController(
      _ uiViewController: UIActivityViewController,
      context: Context
    ) {}
}
