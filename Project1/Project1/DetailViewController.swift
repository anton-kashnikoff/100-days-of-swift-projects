//
//  DetailViewController.swift
//  Project1
//
//  Created by Антон Кашников on 19.02.2023.
//

import UIKit

final class DetailViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet var imageView: UIImageView!

    // MARK: - Public Properties
    var selectedImage: String?
    var selectedPictureNumber = 0
    var totalPictures = 0

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Picture \(selectedPictureNumber) of \(totalPictures)"
        navigationItem.largeTitleDisplayMode = .never
        
        assert(selectedImage != nil, "No image provided")
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
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
}
