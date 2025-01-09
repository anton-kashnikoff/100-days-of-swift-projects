//
//  DetailViewController.swift
//  Project1
//
//  Created by Антон Кашников on 19.02.2023.
//

import UIKit

final class DetailViewController: UIViewController {
    // MARK: - IBOutlet
    
    @IBOutlet private var imageView: UIImageView!

    // MARK: - Public Properties
    
    var selectedImage: String?
    var selectedPictureNumber = 0
    var totalPictures = 0

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Picture \(selectedPictureNumber) of \(totalPictures)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.largeTitleDisplayMode = .never
        
        if let imageToLoad = selectedImage {
            imageView.image = .init(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.hidesBarsOnTap = false
    }

    // MARK: - Private Methods
    
    @objc private func shareTapped() {
        guard let image = imageView.image else {
            print("No image found")
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [
                watermarked(image: image),
                selectedImage ?? .init()
            ],
            applicationActivities: []
        )
        
        if #available(iOS 16.0, *) {
            activityViewController.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItem
        } else {
            activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityViewController, animated: true)
    }

    private func watermarked(image: UIImage) -> UIImage {
        UIGraphicsImageRenderer(size: image.size)
            .image { context in
                image.draw(at: .zero)
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
                
                "From Storm Viewer".draw(
                    with: .init(
                        x: image.size.width - 332,
                        y: image.size.height - 82,
                        width: image.size.width - 32,
                        height: 50
                    ),
                    options: .usesLineFragmentOrigin,
                    attributes: [
                        .strokeWidth: -1,
                        .strokeColor: UIColor.black,
                        .foregroundColor: UIColor.white,
                        .font: UIFont(name: "HelveticaNeue", size: 36)!,
                        .paragraphStyle: paragraphStyle
                    ],
                    context: nil
                )
            }
    }
}
