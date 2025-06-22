//
//  ImageViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

final class ImageViewController: UIViewController {
    private var imageView: UIImageView!
    private var animTimer: Timer!
    
    var image: String?
    
	weak var owner: SelectionViewController?

	override func loadView() {
		super.loadView()
		
		view.backgroundColor = .black

		// create an image view that fills the screen
		imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = .zero

		view.addSubview(imageView)

		// make the image view fill the screen
		imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

		// schedule an animation that does something vaguely interesting
		animTimer = .scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
			// do something exciting with our image
			self.imageView.transform = .identity

			UIView.animate(withDuration: 3) {
				self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let image else { return }
        
		title = image.replacingOccurrences(of: "-Large.jpg", with: "")
        
		let originalImage = UIImage(
            contentsOfFile: Bundle.main.path(
                forResource: image,
                ofType: nil
            )!
        )!

        imageView.image = UIGraphicsImageRenderer(
            size: originalImage.size
        ).image { context in
            context.cgContext.addEllipse(
                in: CGRect(origin: .zero, size: originalImage.size)
            )
            
            context.cgContext.closePath()

            originalImage.draw(at: .zero)
        }
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

        imageView.alpha = .zero

		UIView.animate(withDuration: 3) { [unowned self] in
			self.imageView.alpha = 1
		}
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animTimer.invalidate()
    }

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let image else { return }
        
		let defaults = UserDefaults.standard
		var currentVal = defaults.integer(forKey: image)
		currentVal += 1

		defaults.set(currentVal, forKey:image)

		// tell the parent view controller that it should refresh its table counters when we go back
		owner?.dirty = true
	}
}

@available(iOS 17, *)
#Preview {
    let tempItems = try! FileManager.default.contentsOfDirectory(atPath: Bundle.main.resourcePath!)
    
    let imageViewController = ImageViewController()
    
    imageViewController.image = tempItems.first { item in
        item.range(of: "Large") != nil
    }
    
    let owner = SelectionViewController(style: .plain)
    imageViewController.owner = owner
    
    return imageViewController
}
