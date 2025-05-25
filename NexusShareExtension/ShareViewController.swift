//
//  ShareViewController.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    var sharedURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Grab the first incoming item
        guard let item = extensionContext?
                .inputItems
                .first as? NSExtensionItem,
              let provider = item.attachments?.first else {
            return
        }

        // Pick a single UTI that we support
        let supportedUTIs = [
            UTType.pdf.identifier,
            UTType.spreadsheet.identifier,
            UTType.data.identifier
        ]
        // Find the first matching UTI the provider offers
        let typeIdentifier = provider.registeredTypeIdentifiers
            .first { supportedUTIs.contains($0) }
            ?? UTType.data.identifier

        // Load the file representation for that one UTI
        provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
            guard let url = url else { return }
            // Copy into a temp location
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(url.lastPathComponent)
            try? FileManager.default.removeItem(at: tmpURL)
            try? FileManager.default.copyItem(at: url, to: tmpURL)

            self.sharedURL = tmpURL
            DispatchQueue.main.async {
                self.presentShareUI()
            }
        }
    }

    private func presentShareUI() {
        guard let fileURL = sharedURL else { return }
        // Wrap your SwiftUI ShareContentView
        let content = ShareContentView(sharedURL: fileURL) { folder, name in
            try? SharedFileManager.save(file: fileURL, to: folder, named: name)
            self.extensionContext?
                .completeRequest(returningItems: [], completionHandler: nil)
        }
        let host = UIHostingController(rootView: content)
        addChild(host)
        host.view.frame = view.bounds
        view.addSubview(host.view)
        host.didMove(toParent: self)
    }
}
