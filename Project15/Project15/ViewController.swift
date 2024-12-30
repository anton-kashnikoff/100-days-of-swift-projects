//
//  ViewController.swift
//  Project15
//
//  Created by Антон Кашников on 13/11/2023.
//

import UIKit

final class ViewController: UIViewController {
    
    private var imageView: UIImageView!
    private var currentAnimation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: 512, y: 384)
        
        view.addSubview(imageView)
    }
    
    @IBAction private func buttonTapped(_ sender: UIButton) {
        sender.isHidden = true
        
        /* We don’t need to use [weak self] because there’s no risk of strong reference cycles here.
           The closures passed to animate(withDuration:) method will be used once then thrown away. */
        
//        UIView.animate(withDuration: 1, delay: 0, animations: {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
            switch self.currentAnimation {
            case 0: self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
            case 2: self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)
            case 4: self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
            case 1, 3, 5: self.imageView.transform = .identity
            case 6:
                self.imageView.alpha = 0.1
                self.imageView.backgroundColor = .green
            case 7:
                self.imageView.alpha = 1
                self.imageView.backgroundColor = .clear
            default: break
            }
        }) { _ in
            sender.isHidden = false
        }
        
        currentAnimation += 1
        
        if currentAnimation > 7 { currentAnimation = 0 }
    }
}
