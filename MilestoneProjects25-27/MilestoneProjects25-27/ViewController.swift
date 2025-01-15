//
//  ViewController.swift
//  MilestoneProjects25-27
//
//  Created by Антон Кашников on 13/01/2025.
//

import UIKit

final class ViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Meme maker"

        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(exportPicture)
        )
    }

    private func addLine(with text: String, to direction: Direction) {
        guard let originalImage = imageView.image else { return }
        
        imageView.image = UIGraphicsImageRenderer(size: originalImage.size)
            .image { _ in
                originalImage.draw(
                    in: CGRect(origin: .zero, size: originalImage.size)
                )
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(
                        name: "HelveticaNeue",
                        size: (originalImage.size.height + originalImage.size.width) / 30
                    )!,
                    .foregroundColor: UIColor.white,
                    .strokeWidth: -2,
                    .strokeColor: UIColor.black,
                    .paragraphStyle: paragraphStyle
                ]
                
                let inset = 20
                let width = Int(originalImage.size.width) - inset
                let height = computeTextHeight(
                    for: text,
                    attributes: attributes,
                    width: width
                )
                
                let y = switch direction {
                case .top: inset
                case .bottom: Int(originalImage.size.height) - height - inset
                }
                
                text.draw(
                    with: CGRect(x: inset, y:  y, width: width, height: height),
                    options: .usesLineFragmentOrigin,
                    attributes: attributes,
                    context: nil
                )
            }
    }

    func computeTextHeight(
        for text: String,
        attributes: [NSAttributedString.Key : Any],
        width: Int
    ) -> Int {
        let textRect = NSString(
            string: text
        ).boundingRect(
            with: CGSize(width: CGFloat(width), height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )

        return Int(ceil(textRect.size.height))
    }

    private func showAlert(with title: String, action: @escaping (String) -> Void) {
        let alertController = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )

        alertController.addTextField()
        alertController.addAction(
            UIAlertAction(
                title: "Confirm",
                style: .default
            ) { [weak alertController] _ in
                guard let text = alertController?.textFields?.first?.text else { return }
                guard !text.isEmpty else { return }
                action(text)
            }
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    private var isImageImported: Bool {
        guard imageView.image != nil else {
            let alertController = UIAlertController(
                title: "Error",
                message: "Image not loaded",
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
            return false
        }
        
        return true
    }

    @objc
    private func exportPicture() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
            assertionFailure("Could not convert image to JPEG format.")
            return
        }

        present(
            UIActivityViewController(activityItems: [image], applicationActivities: nil),
            animated: true
        )
    }

    @IBAction private func importPicture() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }

    @IBAction private func setTopText() {
        guard isImageImported else { return }

        showAlert(with: "Enter top line") { [weak self] text in
            self?.addLine(with: text, to: .top)
        }
    }

    @IBAction private func setBottomText() {
        guard isImageImported else { return }

        showAlert(with: "Enter bottom line") { [weak self] text in
            self?.addLine(with: text, to: .bottom)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[.originalImage] as? UIImage else {
            assertionFailure("Could not get original image.")
            dismiss(animated: true)
            return
        }
        
        imageView.image = image

        dismiss(animated: true)
    }
}
