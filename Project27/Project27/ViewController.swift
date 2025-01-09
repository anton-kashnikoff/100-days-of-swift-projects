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
        
        if currentDrawType > 7 {
            currentDrawType = .zero
        }
        
        switch currentDrawType {
        case 0: drawRectangle()
        case 1: drawCircle()
        case 2: drawCheckerboard()
        case 3: drawRotatedSquares()
        case 4: drawLines()
        case 5: drawImagesAndText()
        case 6: drawEmoji()
        case 7: drawTwinText()
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
    
    private func drawImagesAndText() {
        imageView.image = UIGraphicsImageRenderer(
            size: .init(width: 512, height: 512)
        )
        .image { context in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributedString = NSAttributedString(
                string: "The best-laid schemes o'\nmice an' men gang aft agley",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 36),
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            attributedString.draw(
                with: .init(x: 32, y: 32, width: 448, height: 448),
                options: .usesLineFragmentOrigin,
                context: nil
            )

            UIImage(resource: .mouse)
                .draw(at: .init(x: 300, y: 150))
        }
    }

    private func drawEmoji() {
        imageView.image = UIGraphicsImageRenderer(
            size: .init(width: 512, height: 512)
        )
        .image { context in
            UIColor(red: 244 / 255, green: 183 / 255, blue: 70 / 255, alpha: 1).setFill()
            context.cgContext.fillEllipse(
                in: .init(
                    origin: .zero, size: .init(width: 512, height: 512)
                )
            )
            
            UIColor(red: 98 / 255, green: 56 / 255, blue: 18 / 255, alpha: 1).setFill()
            context.cgContext.fillEllipse(
                in: .init(x: 130, y: 150, width: 60, height: 70)
            )
            
            context.cgContext.fillEllipse(
                in: .init(x: 512 - 60 - 130, y: 150, width: 60, height: 70)
            )
            
            UIColor(red: 98 / 255, green: 56 / 255, blue: 18 / 255, alpha: 1).setStroke()
            context.cgContext.setLineWidth(10)
            context.cgContext.setLineCap(.round)
            context.cgContext.move(to: .init(x: 130, y: 400))
            context.cgContext.addLine(to: .init(x: 512 - 130, y: 350))
            context.cgContext.strokePath()
        }
    }

    private func drawTwinText() {
        let imageWidth = 512
        let imageHeight = 512
        let renderer = UIGraphicsImageRenderer(size: .init(width: imageWidth, height: imageHeight))

        // those 2 parameters alone determine the text size, and can be changed
        let height = 150
        let spacing = 40

        // center text vertically
        let top: Int = (imageHeight - height) / 2
        let bottom = top + height
        
        // width is proportional to height
        let width: Int = height * 2 / 3
        
        // center text horizontally
        //                          T                 W             I             N
        var startx = (imageWidth - (width + spacing + width + spacing + spacing + width)) / 2
        
        imageView.image = renderer.image { context in
            drawT(context: context.cgContext, top: top, bottom: bottom, startx: startx, width: width)

            startx += width + spacing
            drawW(context: context.cgContext, top: top, bottom: bottom, startx: startx, width: width)

            startx += width + spacing
            drawI(context: context.cgContext, top: top, bottom: bottom, startx: startx, width: width)

            startx += spacing
            drawN(context: context.cgContext, top: top, bottom: bottom, startx: startx, width: width)

            UIColor.black.setStroke()
            context.cgContext.setLineWidth(10)
            context.cgContext.setLineJoin(.round)
            context.cgContext.setLineCap(.round)
            context.cgContext.drawPath(using: .stroke)
        }
    }

    private func drawT(context: CGContext, top: Int, bottom: Int, startx: Int, width: Int) {
        context.move(to: .init(x: startx, y: top))
        context.addLine(to: .init(x: startx + width, y: top))
        context.move(to: .init(x: startx + width/2, y: top))
        context.addLine(to: .init(x: startx + width/2, y: bottom))
    }
    
    private func drawW(context: CGContext, top: Int, bottom: Int, startx: Int, width: Int) {
        context.move(to: .init(x: startx, y: top))
        context.addLine(to: .init(x: Double(startx) + Double(width) * 0.3, y: Double(bottom)))
        context.addLine(to: .init(x: Double(startx) + Double(width) * 0.5, y: Double((top + bottom) / 2)))
        context.addLine(to: .init(x: Double(startx) + Double(width) * 0.7, y: Double(bottom)))
        context.addLine(to: .init(x: startx + width, y: top))
    }

    private func drawI(context: CGContext, top: Int, bottom: Int, startx: Int, width: Int) {
        context.move(to: .init(x: startx, y: top))
        context.addLine(to: .init(x: startx, y: bottom))
    }

    private func drawN(context: CGContext, top: Int, bottom: Int, startx: Int, width: Int) {
        context.move(to: .init(x: startx, y: bottom))
        context.addLine(to: .init(x: startx, y: top))
        context.addLine(to: .init(x: startx + width, y: bottom))
        context.addLine(to: .init(x: startx + width, y: top))
    }
}
