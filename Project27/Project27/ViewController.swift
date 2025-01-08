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
        case 3: drawRotatedSquares()
        case 4: drawLines()
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

    // In UIKit, you rotate drawing around the center of your view,
    // as if a pin was stuck right through the middle. In Core Graphics,
    // you rotate around the top-left corner, so to avoid that we're going
    // to move the transformation matrix half way into our image first
    // so that we've effectively moved the rotation point.
    
    // This also means we need to draw our rotated squares so
    // they are centered on our center: for example,
    // setting their top and left coordinates to be -128 and their width and height to be 256.
    private func drawRotatedSquares() {
        imageView.image = UIGraphicsImageRenderer(
            size: .init(width: 512, height: 512)
        )
        .image { context in
            context.cgContext.translateBy(x: 256, y: 256)

            let rotations = 16
            let amount = Double.pi / Double(rotations)
            
            // Modifying the CTM is cumulative.
            // That is, when you rotate the CTM, that transformation is applied
            // on top of what was there already, rather than to a clean slate.
            // So the code works by rotating the CTM a small amount more every time the loop goes around.
            for _ in 0..<rotations {
                context.cgContext.rotate(by: CGFloat(amount))
                context.cgContext.addRect(.init(x: -128, y: -128, width: 256, height: 256))
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
    }

    private func drawLines() {
        imageView.image = UIGraphicsImageRenderer(
            size: .init(width: 512, height: 512)
        )
        .image { context in
            context.cgContext.translateBy(x: 256, y: 256)

            var isFirst = true
            var length: CGFloat = 256
            
            for _ in 0..<256 {
                context.cgContext.rotate(by: .pi / 2) // 90°
                
                if isFirst {
                    context.cgContext.move(to: .init(x: length, y: 50))
                    isFirst = false
                } else {
                    context.cgContext.addLine(to: .init(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
    }
}
