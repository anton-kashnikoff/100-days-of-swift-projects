//
//  ViewController.swift
//  Project25
//
//  Created by Антон Кашников on 24/11/2024.
//

import MultipeerConnectivity
import UIKit

final class ViewController: UICollectionViewController {
    // MARK: - Private Properties

    private let peerID = MCPeerID(displayName: UIDevice.current.name)

    private var images = [UIImage]()
    private var session: MCSession?
    private var advertiserAssistant: MCAdvertiserAssistant?

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Selfie Share"
        navigationItem.leftBarButtonItems = [
            .init(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(showConnectionPrompt)
            ),
            .init(
                title: "Peers",
                style: .plain,
                target: self,
                action: #selector(showPeersPrompt)
            )
        ]

        navigationItem.rightBarButtonItems = [
            .init(
                barButtonSystemItem: .camera,
                target: self,
                action: #selector(importPicture)
            ),
            .init(
                barButtonSystemItem: .compose,
                target: self,
                action: #selector(showSendMessagePrompt)
            )
        ]
    
        session = .init(peer: peerID)
        session?.delegate = self
    }

    // MARK: - UICollectionViewController

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        images.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ImageViewCell",
            for: indexPath
        )

        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }

        return cell
    }

    // MARK: - Private Methods

    private func startHosting(action: UIAlertAction) {
        guard let session else { return }

        advertiserAssistant = .init(
            serviceType: "hws-project25",
            discoveryInfo: nil,
            session: session
        )

        advertiserAssistant?.start()
    }

    private func joinSession(action: UIAlertAction) {
        guard let session else { return }
        
        let browserViewController = MCBrowserViewController(
            serviceType: "hws-project25",
            session: session
        )

        browserViewController.delegate = self
        present(browserViewController, animated: true)
    }

    private func sendMessage(_ text: String) {
        sendData(.init(text.utf8))
    }

    private func sendData(_ data: Data) {
        guard let session else { return }

        if !session.connectedPeers.isEmpty {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                let alertController = UIAlertController(
                    title: "Send error",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )

                alertController.addAction(.init(title: "OK", style: .default))
                present(alertController, animated: true)
            }
        }
    }

    @objc
    private func showPeersPrompt() {
        guard let session else { return }

        let text = if !session.connectedPeers.isEmpty {
            session.connectedPeers.reduce(String()) { partialResult, peerID in
                partialResult + "\n\(peerID.displayName)"
            }
        } else {
            "No peer connected"
        }

        let alertController = UIAlertController(
            title: "Connected peers",
            message: text,
            preferredStyle: .actionSheet
        )

        alertController.addAction(.init(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    @objc
    private func showSendMessagePrompt() {
        let alertController = UIAlertController(
            title: "Enter a message",
            message: nil,
            preferredStyle: .alert
        )

        alertController.addTextField()
        alertController.addAction(
            .init(title: "Send", style: .default) { [weak self] _ in
                if let text = alertController.textFields?.first?.text {
                    self?.sendMessage(text)
                }
            }
        )
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    @objc
    private func showConnectionPrompt() {
        let alertController = UIAlertController(
            title: "Connect to others",
            message: nil,
            preferredStyle: .alert
        )

        alertController
            .addAction(
                .init(title: "Host a session", style: .default, handler: startHosting)
            )

        alertController
            .addAction(
                .init(title: "Join a session", style: .default, handler: joinSession)
            )

        alertController.addAction(.init(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    @objc
    private func importPicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true)
    }
}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        images.insert(image, at: 0)
        collectionView.reloadData()

        if let imageData = image.pngData() {
            sendData(imageData)
        }
    }
}

// MARK: - MCSessionDelegate

extension ViewController: MCSessionDelegate {
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")

            let alertController = UIAlertController(
                title: "Disconnected",
                message: "\(peerID.displayName) disconnected",
                preferredStyle: .alert
            )

            alertController.addAction(.init(title: "OK", style: .default))
            present(alertController, animated: true)
        @unknown default:
            print("Unknown state received: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            } else {
                let alertController = UIAlertController(
                    title: "Message received",
                    message: String(decoding: data, as: UTF8.self),
                    preferredStyle: .alert
                )

                alertController.addAction(.init(title: "OK", style: .default))
                self?.present(alertController, animated: true)
            }
        }
    }
    
    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {}
    
    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {}
    
    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: (any Error)?
    ) {}
}

// MARK: - MCBrowserViewControllerDelegate

extension ViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(
        _ browserViewController: MCBrowserViewController
    ) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(
        _ browserViewController: MCBrowserViewController
    ) {
        dismiss(animated: true)
    }
}
