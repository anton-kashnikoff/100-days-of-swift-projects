//
//  Card.swift
//  MilestoneProjects28-30
//
//  Created by Антон Кашников on 23/06/2025.
//

enum CardState {
    case front, back, matched, complete
}

final class Card {
    var state = CardState.back
    var frontImage: String
    var backImage: String
    
    init(frontImage: String, backImage: String) {
        self.frontImage = frontImage
        self.backImage = backImage
    }
}
