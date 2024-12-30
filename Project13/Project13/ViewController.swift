//
//  ViewController.swift
//  Project13
//
//  Created by Антон Кашников on 04/11/2023.
//

import CoreImage
import UIKit

final class ViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var intensity: UISlider!
    @IBOutlet private var radius: UISlider!
    @IBOutlet private var changeFilterButton: UIButton!
    
    // MARK: - Private properties
    
    private var currentImage: UIImage!
    private var context: CIContext!
    private var currentFilter: CIFilter!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(importPicture)
        )
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    // MARK: - Private methods
    
    private func applyProcessing(filterType: String = kCIInputIntensityKey + kCIInputRadiusKey) {
        guard let image = currentFilter.outputImage else { return }
        
        let inputKeys = currentFilter.inputKeys
        
        switch filterType {
        case kCIInputIntensityKey:
            if inputKeys.contains(kCIInputIntensityKey) {
                currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            }
        case kCIInputRadiusKey:
            if inputKeys.contains(kCIInputRadiusKey) {
                currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
            }
        default:
            if inputKeys.contains(kCIInputIntensityKey) {
                currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            }
            
            if inputKeys.contains(kCIInputRadiusKey) {
                currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
            }
        }
        
        if let cgImage = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    
    private func showFiltersAlert() {
        let filters = ["CIBumpDistortion", "CIGaussianBlur", "CIPixellate", "CISepiaTone", "CITwirlDistortion", "CIUnsharpMask", "CIVignette"]
        let alertController = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        
        filters.forEach {
            alertController.addAction(UIAlertAction(title: $0, style: .default, handler: setFilter))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func setCurrentImageAsInput() {
        currentFilter.setValue(CIImage(image: currentImage), forKey: kCIInputImageKey)
    }
    
    @objc
    private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        if let error {
            alertController.title = "Save error"
            alertController.message = error.localizedDescription
        } else {
            alertController.title = "Saved!"
            alertController.message = "Your altered image has been saved to your photos."
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc
    private func importPicture() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc
    private func setFilter(action: UIAlertAction) {
        guard
            currentImage != nil,
            let actionTitle = action.title
        else { return }
        
        currentFilter = CIFilter(name: actionTitle)
        
        changeFilterButton.setTitle(actionTitle, for: .normal)
        
        setCurrentImageAsInput()
        applyProcessing()
    }
    
    // MARK: - IBActions

    @IBAction func changeFilter(_ sender: UIButton) {
        showFiltersAlert()
    }
    
    @IBAction func save(_ sender: UIButton) {
        guard let image = imageView.image else {
            let alertController = UIAlertController(
                title: "Error", message: "There's no image in the image view.", preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
            
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        applyProcessing(filterType: kCIInputIntensityKey)
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        applyProcessing(filterType: kCIInputRadiusKey)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[.editedImage] as? UIImage else { return }

        currentImage = image
        
        setCurrentImageAsInput()
        applyProcessing()
        
        imageView.alpha = 0
        
        dismiss(animated: true) { [weak self] in
            UIView.animate(withDuration: 1) { self?.imageView.alpha = 1 }
        }
    }
}
