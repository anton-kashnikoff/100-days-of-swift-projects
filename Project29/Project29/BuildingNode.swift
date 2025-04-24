//
//  BuildingNode.swift
//  Project29
//
//  Created by Антон Кашников on 16/04/2025.
//

import SpriteKit

final class BuildingNode: SKSpriteNode {
    private var currentImage: UIImage!
    
    private func drawBuilding(size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            let color = switch Int.random(in: 0...2) {
            case 0: UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1: UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default: UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            color.setFill()
            context.cgContext.addRect(CGRect(origin: .zero, size: size))
            context.cgContext.drawPath(using: .fill)
            
            for row in stride(from: 10, to: Int(size.height) - 10, by: 40) {
                for col in stride(from: 10, to: Int(size.width) - 10, by: 40) {
                    let color = if Bool.random() {
                        UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
                    } else {
                        UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
                    }
                    
                    color.setFill()
                    context.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }
    }
    
    private func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    func setup() {
        name = "building"
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        configurePhysics()
    }
    
    func hit(at point: CGPoint) {
        // Figure out where the building was hit. SpriteKit's positions things from the center and Core Graphics from the bottom left!
        let convertedPoint = CGPoint(
            x: point.x + size.width / 2,
            y: abs(point.y - size.height / 2)
        )
        
        let image = UIGraphicsImageRenderer(size: size).image { context in
            // Draw our current building image into the context.
            // This will be the full building to begin with, but it will change when hit.
            currentImage.draw(at: .zero)
            
            context.cgContext.addEllipse(
                in: CGRect(
                    x: convertedPoint.x - 32,
                    y: convertedPoint.y - 32,
                    width: 64,
                    height: 64
                )
            )
            
            // literally cutting an ellipse out of our image
            context.cgContext.setBlendMode(.clear)
            context.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: image)
        currentImage = image
        
        configurePhysics()
    }
}
