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
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = item.attachments?.first else {
            return
        }
        let types: [UTType] = [.pdf, .spreadsheet]
        provider.loadFileRepresentation(
            forTypeIdentifier: types.map { $0.identifier }
        ) { url, error in
            guard let fileURL = url else { return }
            let tmp = FileManager.default.temporaryDirectory
              .appendingPathComponent(fileURL.lastPathComponent)
            try? FileManager.default.copyItem(at: fileURL, to: tmp)
            self.sharedURL = tmp
            DispatchQueue.main.async {
                self.presentPicker()
            }
        }
    }

    private func presentPicker() {
        guard let sharedURL else { return }
        let vc = UIHostingController(
            rootView: ShareContentView(
                sharedURL: sharedURL,
                onSave: { folder, name in
                    try? SharedFileManager.save(
                      file: sharedURL, to: folder, named: name)
                    self.extensionContext?
                      .completeRequest(returningItems: [], completionHandler: nil)
                }
            )
        )
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
}
