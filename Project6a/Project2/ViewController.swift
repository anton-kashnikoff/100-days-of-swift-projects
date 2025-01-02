//
//  ViewController.swift
//  Project2
//
//  Created by Антон Кашников on 22.02.2023.
//

import UIKit

final class ViewController: UIViewController {
    // MARK: - IBOutlet
    
    @IBOutlet private var button1: UIButton!
    @IBOutlet private var button2: UIButton!
    @IBOutlet private var button3: UIButton!

    // MARK: - Private Properties
    
    private var countries = [String]()
    private var correctAnswer = 0
    private var score = 0
    private var countOfAnswers = 0

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show Score", style: .done, target: self, action: #selector(showScore))
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        askQuestion(action: nil)
    }

    // MARK: - IBAction
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String

        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong! That’s the flag of \(countries[sender.tag].uppercased())"
            score -= 1
        }
        
        countOfAnswers += 1
        
        if countOfAnswers == 10 {
            let ac = UIAlertController(title: "Congratulations!", message: "Your final score is \(score)", preferredStyle: .alert)
            ac.addAction(.init(title: "Continue", style: .default) { action in
                self.score = .zero
                self.countOfAnswers = .zero
                self.askQuestion(action: nil)
            })
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: title, message: "Your score is \(score).", preferredStyle: .alert)
            ac.addAction(.init(title: "Continue", style: .default, handler: askQuestion))
            present(ac, animated: true)
        }
    }

    // MARK: - Private Methods
    
    private func askQuestion(action: UIAlertAction!) {
        countries.shuffle()
        
        button1.setImage(.init(named: countries[0]), for: .normal)
        button2.setImage(.init(named: countries[1]), for: .normal)
        button3.setImage(.init(named: countries[2]), for: .normal)
        
        correctAnswer = Int.random(in: 0...2)
        title = countries[correctAnswer].uppercased() + " Score: \(score)"
    }
    
    @objc private func showScore() {
        let alertVC = UIAlertController(title: "Your score is \(score)", message: nil, preferredStyle: .alert)
        alertVC.addAction(.init(title: "OK", style: .default))
        present(alertVC, animated: true)
    }
}
