//
//  ViewController.swift
//  Project27
//
//  Created by Антон Кашников on 08/01/2025.
//

import UIKit

final class ViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!

    private var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRectangle()
    }

    @IBAction private func redrawTapped() {
        currentDrawType += 1
        
        if currentDrawType > 5 {
            currentDrawType = .zero
        }
        
        switch currentDrawType {
        case 0: drawRectangle()
        default: break
        }
    }

    private func drawRectangle() {
        let imageRenderer = UIGraphicsImageRenderer(
            size: .init(width: 512, height: 512)
        )

        let image = imageRenderer.image { context in
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            context.cgContext.addRect(
                .init(origin: .zero, size: .init(width: 512, height: 512))
            )

            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
}
