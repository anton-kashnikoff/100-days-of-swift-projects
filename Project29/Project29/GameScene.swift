//
//  GameScene.swift
//  Project29
//
//  Created by Антон Кашников on 16/04/2025.
//

import SpriteKit

final class GameScene: SKScene {
    private var buildings = [BuildingNode]()
    
    private var player1: SKSpriteNode!
    private var player2: SKSpriteNode!
    private var banana: SKSpriteNode!
    
    private var currentPlayer = 1
    
    weak var viewController: GameViewController!

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        physicsWorld.contactDelegate = self
        
        createBuildings()
        createPlayers()
    }
    
    private func createBuildings() {
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: .random(in: 2...4) * 40, height: .random(in: 300...600))
            currentX += size.width + 2
            
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - size.width / 2, y: size.height / 2)
            building.setup()
            
            addChild(building)
            buildings.append(building)
        }
    }
    
    private func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        let player1Building = buildings[1]
        player1.position = CGPoint(
            x: player1Building.position.x,
            y: player1Building.position.y + (player1Building.size.height + player1.size.height) / 2
        )
        
        addChild(player1)
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false

        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(
            x: player2Building.position.x,
            y: player2Building.position.y + (player2Building.size.height + player2.size.height) / 2
        )
        
        addChild(player2)
    }
    
    private func deg2rad(degrees: Int) -> Double {
        Double(degrees) * .pi / 180
    }
    
    private func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        viewController.playerScored(player: player == player1 ? 2 : 1)
        
        if !viewController.gameOver {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.newGame()
            }
        }
    }
    
    private func changePlayer() {
        currentPlayer = currentPlayer == 1 ? 2 : 1
        
        viewController.activatePlayer(number: currentPlayer)
    }
    
    private func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        
        building.hit(at: convert(contactPoint, to: building))
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        // fix a small but annoying bug: if a banana just so happens to hit two buildings at the same time,
        // then it will explode twice and thus call changePlayer() twice – effectively giving the player another throw.
        // By clearing the banana's name here, the second collision won't happen because our didBegin() method
        // won't see the banana as being a banana any more – its name is gone.
        banana.name = String()
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    func launch(angle: Int, velocity: Int) {
        // Figure out how hard to throw the banana.
        let speed = Double(velocity) / 10
        
        // Convert the input angle to radians.
        let radians = deg2rad(degrees: angle)
        
        // If somehow there's a banana already, we'll remove it then create a new one using circle physics.
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        physicsWorld.gravity = viewController.wind.getGravity(player: currentPlayer)
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        if currentPlayer == 1 {
            // If player 1 was throwing the banana, we position it up and to the left of the player and give it some spin.
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            // Animate player 1 throwing their arm up then putting it down again.
            player1.run(
                .sequence([
                    .setTexture(SKTexture(imageNamed: "player1Throw")),
                    .wait(forDuration: 0.15),
                    .setTexture(SKTexture(imageNamed: "player"))
                ])
            )
            
            // Make the banana move in the correct direction.
            banana.physicsBody?.applyImpulse(
                CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            )
        } else {
            // If player 2 was throwing the banana, we position it up and to the right, apply the opposite spin, then make it move in the correct direction.
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            player1.run(
                .sequence([
                    .setTexture(SKTexture(imageNamed: "player2Throw")),
                    .wait(forDuration: 0.15),
                    .setTexture(SKTexture(imageNamed: "player"))
                ])
            )
            
            banana.physicsBody?.applyImpulse(
                CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            )
        }
    }
    
    func newGame() {
        let newGame = GameScene(size: size)
        newGame.viewController = viewController
        viewController.currentGame = newGame
        
        changePlayer()
        
        // whoever died gets the first shot.
        newGame.currentPlayer = currentPlayer
        
        view?.presentScene(newGame, transition: .doorway(withDuration: 1.5))
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: @preconcurrency SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let (firstBody, secondBody) = if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            (contact.bodyA, contact.bodyB)
        } else {
            (contact.bodyB, contact.bodyA)
        }
        
        guard let firstNode = firstBody.node,
              let secondNode = secondBody.node
        else { return }
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
}
