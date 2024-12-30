//
//  TableViewController.swift
//  Project5
//
//  Created by Антон Кашников on 27.05.2023.
//

import UIKit

final class TableViewController: UITableViewController {
    // MARK: - Private properties
    private var allWords = [String]()
    private var gameState = GameState(currentWord: "", usedWords: [])

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startNewGame))

        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"), let startWords = try? String(contentsOf: startWordsURL) {
            allWords = startWords.components(separatedBy: .newlines)
        }

        if allWords.isEmpty {
            allWords = ["silkworm"]
        }

        performSelector(inBackground: #selector(startGame), with: nil)
    }

    // MARK: - Private Methods
    @objc private func startGame() {
        if let loadedState = UserDefaults.standard.object(forKey: "GameState") as? Data, let decodedState = try?  JSONDecoder().decode(GameState.self, from: loadedState) {
            self.gameState = decodedState
        }
        
        if gameState.currentWord.isEmpty {
            startNewGame()
        }
        
        performSelector(onMainThread: #selector(loadGameStateView), with: nil, waitUntilDone: false)
    }
    
    @objc private func startNewGame() {
        DispatchQueue.global().async {
            self.gameState.currentWord = self.allWords.randomElement() ?? "silkworm"
            self.gameState.usedWords.removeAll(keepingCapacity: true)
            
            self.saveGameState()
            self.performSelector(onMainThread: #selector(self.loadGameStateView), with: nil, waitUntilDone: false)
        }
    }
    
    @objc func loadGameStateView() {
        title = gameState.currentWord
        tableView.reloadData()
    }

    @objc private func promptForAnswer() {
        let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let submitAlertAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in
            guard let answer = alertController?.textFields?[0].text else {
                return
            }
            self?.submit(answer)
        }

        alertController.addAction(submitAlertAction)
        present(alertController, animated: true)
    }
    
    @objc private func saveGameState() {
        if let encodedState = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(encodedState, forKey: "GameState")
        }
    }

    private func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()

        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    gameState.usedWords.insert(lowerAnswer, at: 0)

//                    performSelector(inBackground: #selector(saveGameState), with: nil)
                    saveGameState()
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                } else {
                    showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
                }
            } else {
                showErrorMessage(title: "Word used already", message: "Be more original!")
            }
        } else {
            guard let title = title?.lowercased() else {
                return
            }
            showErrorMessage(title: "Word not possible", message: "You can't spell that word from \(title)")
        }
    }

    private func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {
            return false
        }
        
        if tempWord == word {
            return false
        }

        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }

        return true
    }

    private func isOriginal(word: String) -> Bool {
        !gameState.usedWords.contains(word)
    }

    private func isReal(word: String) -> Bool {
        let misspelledRange = UITextChecker().rangeOfMisspelledWord(in: word, range: NSRange(location: 0, length: word.utf16.count), startingAt: 0, wrap: false, language: "en")

        if word.count < 3 {
            return false
        }

        return misspelledRange.location == NSNotFound
    }

    private func showErrorMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewController
extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        gameState.usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = gameState.usedWords[indexPath.row]
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = gameState.usedWords[indexPath.row]
        }

        return cell
    }
}
