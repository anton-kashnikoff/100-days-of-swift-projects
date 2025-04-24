//
//  GameViewController.swift
//  Project29
//
//  Created by Антон Кашников on 16/04/2025.
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    @IBOutlet private var angleSlider: UISlider!
    @IBOutlet private var angleLabel: UILabel!
    @IBOutlet private var velocitySlider: UISlider!
    @IBOutlet private var velocityLabel: UILabel!
    @IBOutlet private var launchButton: UIButton!
    @IBOutlet private var playerNumberLabel: UILabel!
    @IBOutlet private var player1ScoreLabel: UILabel!
    @IBOutlet private var player2ScoreLabel: UILabel!
    @IBOutlet private var newGameButton: UIButton!
    @IBOutlet private var player1WindLabel: UILabel!
    @IBOutlet private var player2WindLabel: UILabel!
    
    var currentGame: GameScene!
    
    var player1Score = Int() {
        didSet {
            player1ScoreLabel.text = "Score: \(player1Score)"
        }
    }
    
    var player2Score = Int() {
        didSet {
            player2ScoreLabel.text = "Score: \(player2Score)"
        }
    }
    
    var gameOver = false {
        didSet {
            newGameButton.isHidden = !gameOver
        }
    }
    
    var wind: Wind!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            .allButUpsideDown
        } else {
            .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameOver = false
        player1Score = 0
        player2Score = 0
        
        wind = .randomWind
        player1WindLabel.attributedText = wind.text
        player1WindLabel.isHidden = false
        player2WindLabel.isHidden = true
        
        if let view = self.view as! SKView? {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
                
                currentGame = scene as? GameScene
                currentGame.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        angleChanged()
        velocityChanged()
    }
    
    @IBAction private func angleChanged() {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBAction private func velocityChanged() {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBAction private func launch() {
        toggleControls(show: false)
        
        currentGame.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
    
    @IBAction private func newGame() {
        gameOver = false
        player1Score = 0
        player2Score = 0
        currentGame.newGame()
    }
    
    private func toggleControls(show: Bool) {
        [
            angleSlider,
            angleLabel,
            velocitySlider,
            velocityLabel,
            launchButton
        ].forEach {
            $0.isHidden = !show
        }
    }
    
    private func stopGame() {
        toggleControls(show: false)
        gameOver = true
    }
    
    func activatePlayer(number: Int) {
        wind = .randomWind
        
        if number == 1 {
            playerNumberLabel.text = "<<< PLAYER ONE"
            player1WindLabel.attributedText = wind.text
            player1WindLabel.isHidden = false
            player2WindLabel.isHidden = true
        } else {
            playerNumberLabel.text = "PLAYER TWO >>>"
            player2WindLabel.attributedText = wind.text
            player2WindLabel.isHidden = false
            player1WindLabel.isHidden = true
        }
        
        toggleControls(show: true)
    }
    
    func playerScored(player: Int) {
        if player == 1 { player1Score += 1 } else { player2Score += 1 }
        
        if player1Score == 3 {
            playerNumberLabel.text = "PLAYER ONE WINS!"
            stopGame()
        } else if player2Score == 3 {
            playerNumberLabel.text = "PLAYER TWO WINS!"
            stopGame()
        }
    }
}
