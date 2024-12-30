//
//  GameState.swift
//  Project5
//
//  Created by Антон Кашников on 03.07.2023.
//

import Foundation

struct GameState: Codable {
    var currentWord: String
    var usedWords: [String]
}
