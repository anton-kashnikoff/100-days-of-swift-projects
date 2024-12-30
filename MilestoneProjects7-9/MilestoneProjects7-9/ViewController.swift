//
//  ViewController.swift
//  MilestoneProjects7-9
//
//  Created by Антон Кашников on 09.06.2023.
//

import UIKit

final class ViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet private var wordToGuessLabel: UILabel!
    @IBOutlet private var wrongAnswersLabel: UILabel!
    @IBOutlet private var enterLetterButton: UIButton!

    // MARK: - Private Properties
    private var allWords = [String]()
    private var usedLetters = [Character]()
    private var wrongAnswersCount = 0
    private var currentWord = ""
    private var promptWord = ""

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        enterLetterButton.layer.cornerRadius = 10
        enterLetterButton.layer.borderWidth = 1

        if #available(iOS 15.0, *) {
            enterLetterButton.layer.borderColor = UIColor.tintColor.cgColor
        }

        performSelector(inBackground: #selector(loadWords), with: nil)
        startNewGame()
    }

    // MARK: - Private Methods
    private func startNewGame() {
        promptWord.removeAll()
        usedLetters.removeAll()
        wrongAnswersCount = 0
        wrongAnswersLabel.text = "Wrong answers: \(wrongAnswersCount)"
        currentWord = allWords.randomElement() ?? ""
        checkTheWord()
    }
    
    private func checkTheWord() {
        for letter in currentWord {
            if usedLetters.contains(letter) {
                promptWord += String(letter)
            } else {
                promptWord += "?"
            }
        }

        wordToGuessLabel.text = promptWord

        if !promptWord.contains("?") {
            showEndLevelAlert(title: "Congratulations! You win!", message: "Tap \"OK\" to start new level.")
            startNewGame()
        }
    }

    private func submit(_ answer: String) {
        let letter = Character(answer)

        if currentWord.contains(letter) {
            usedLetters.append(letter)
        } else {
            wrongAnswersCount += 1
            wrongAnswersLabel.text = "Wrong answers: \(wrongAnswersCount)"

            if wrongAnswersCount == 7 {
                showEndLevelAlert(title: "Sorry! Game over!", message: "Your word was \(currentWord).") { [weak self] _ in
                    self?.startNewGame()
                }
            }
        }
        
        promptWord.removeAll()
        checkTheWord()
    }

    private func showEndLevelAlert(title: String, message: String, action: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: action))

        present(alertController, animated: true)
    }

    private func promptForLetter() {
        let alertController = UIAlertController(title: "Enter a letter", message: "You can enter only 1 (one) letter", preferredStyle: .alert)
        alertController.addTextField()
        alertController.addAction(UIAlertAction(title: "Enter", style: .default) { [weak self, weak alertController] _ in
            guard let answer = alertController?.textFields?[0].text?.uppercased() else {
                return
            }

            if answer.count != 1 {
                return
            } else {
                self?.submit(answer)
            }
        })

        present(alertController, animated: true)
    }

    @objc private func loadWords() {
        if let wordsURL = Bundle.main.url(forResource: "words", withExtension: "txt"), let words = try? String(contentsOf: wordsURL) {
            allWords = words.components(separatedBy: .newlines)
        }
        
        if allWords.isEmpty {
            allWords = ["SILKWORM"]
        }
    }

    // MARK: - IBAction
    @IBAction private func enterLetterButtonTapped(_ sender: UIButton) {
        promptForLetter()
    }
}
