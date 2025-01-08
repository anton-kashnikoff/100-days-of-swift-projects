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
        case 1: drawCircle()
        case 2: drawCheckerboard()
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

    private func drawCircle() {
        let imageRenderer = UIGraphicsImageRenderer(
            size: .init(width: 512, height: 512)
        )

        let lineWidth: CGFloat = 10

        let image = imageRenderer.image { context in
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(lineWidth)
            context.cgContext.addEllipse(
                in: .init(
                    origin: .zero, size: .init(width: 512, height: 512)
                )
                .insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
            )

            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }

    private func drawCheckerboard() {
        let imageRenderer = UIGraphicsImageRenderer(
            size: .init(width: 512, height: 512)
        )

        let image = imageRenderer.image { context in
            context.cgContext.setFillColor(UIColor.black.cgColor)

            for row in 0..<8 {
                for col in 0..<8 {
                    if (row + col).isMultiple(of: 2) {
                        context.cgContext.fill(
                            .init(x: col * 64, y: row * 64, width: 64, height: 64)
                        )
                    }
                }
            }
        }
        
        imageView.image = image
    }
}
