//
//  GameCollectionViewController.swift
//  MilestoneProjects28-30
//
//  Created by Антон Кашников on 23/06/2025.
//

import UIKit

private let reuseIdentifier = "Cell"

final class GameCollectionViewController: UICollectionViewController {
    private let cardsDirectory = "Cards.bundle/"
    
    private var currentCards = "Characters"
    private var currentGrid = 4
    private var currentGridElement = 1
    private var cardSize: CardSize!
    private var currentCardSize: CGSize!
    private var cards = [Card]()
    private var flippedCards = [(position: Int, card: Card)]()
    private var currentCardSizeValid = false
    private var flipAnimator = FlipCardAnimator()
    private var matchedCardsAnimators = [MatchedCardsAnimator]()
    private var unmatchedCardsAnimator = UnmatchedCardsAnimator()
    private var completionAnimator = CompletionAnimator()
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pairs"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "New game",
            style: .plain,
            target: self,
            action: #selector(newGame)
        )

        let (gridSide1, gridSide2) = grids[currentGrid].combinations[currentGridElement]
        
        cardSize = CardSize(
            imageSize: CGSize(width: 50, height: 50),
            gridSide1: gridSide1,
            gridSide2: gridSide2
        )

        newGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCardSize()
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: any UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        updateCardSize()
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        cards.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as? CardCollectionViewCell else {
            return UICollectionViewCell()
        }
    
        cell.set(card: cards[indexPath.row])
    
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(
            at: indexPath
        ) as? CardCollectionViewCell else {
            return
        }

        guard cards[indexPath.row].state == .back else { return }

        cards[indexPath.row].state = .front

        if flippedCards.isEmpty {
            flipAnimator.flipTo(state: .front, cell: cell)
            flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))
            return
        }

        if flippedCards.count == 1 {
            flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))

            if flippedCards[0].card.frontImage == flippedCards[1].card.frontImage {
                matchCards()
            } else {
                unmatchCards()
            }
            
            return
        }

        if flippedCards.count == 2 {
            // one of the two front facing cards
            if indexPath.row == flippedCards[0].position || indexPath.row == flippedCards[1].position {
                cards[indexPath.row].state = .back
                forceFinishUnmatchCards()
                return
            }
            // another card
            forceFinishUnmatchCards()
            flipAnimator.flipTo(state: .front, cell: cell)
            flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))
            return
        }
    }
    
    // MARK: - Private Methods
    
    @objc
    private func newGame() {
        let (gridSide1, gridSide2) = grids[currentGrid].combinations[currentGridElement]
        
        guard (gridSide1 * gridSide2).isMultiple(of: 2) else {
            fatalError("Odd number of cards")
        }
        
        cardSize.gridSide1 = gridSide1
        cardSize.gridSide2 = gridSide2
        
        cards.removeAll()
        resetFlippedCards()
        cancelAnimators()
        
        loadCards()
        
        currentCardSizeValid = false
        collectionView.reloadData()
    }
    
    private func resetFlippedCards() {
        flippedCards.removeAll(keepingCapacity: true)
    }
    
    private func cancelAnimators() {
        flipAnimator.cancel()
        unmatchedCardsAnimator.cancel()
        matchedCardsAnimators.forEach { $0.cancel()}
        matchedCardsAnimators.removeAll()
        completionAnimator.cancel()
    }
    
    private func loadCards() {
        var backImage: String?
        var frontImages = [String]()

        guard let urls = Bundle.main.urls(
            forResourcesWithExtension: nil,
            subdirectory: cardsDirectory + currentCards
        ) else {
            fatalError(#function + ": Cannot find cards directory \(cardsDirectory)\(currentCards)")
        }
        
        for url in urls {
            // convention: unique names to avoid caching issue and starting with 1 for sorting
            if url.lastPathComponent.starts(with: "1\(currentCards)_back.") {
                backImage = url.path
            } else {
                frontImages.append(url.path)
            }
        }

        guard let backImage else { fatalError("No back image found") }
        guard let size = UIImage(named: backImage)?.size else {
            fatalError("Cannot get image size")
        }
        
        cardSize.imageSize = size

        let (gridSide1, gridSide2) = grids[currentGrid].combinations[currentGridElement]
        let cardsNumber = gridSide1 * gridSide2
        
        // more images than required grid
        while frontImages.count > cardsNumber / 2 {
            frontImages.remove(at: .random(in: 0..<frontImages.count))
        }
        // not enough images to fill grid
        while frontImages.count < cardsNumber / 2 {
            frontImages.append(frontImages[.random(in: 0..<frontImages.count)])
        }
        
        // duplicate all images to make pairs
        frontImages += frontImages

        frontImages.shuffle()

        for i in 0..<cardsNumber {
            cards.append(Card(frontImage: frontImages[i], backImage: backImage))
        }
    }
    
    private func updateCardSize() {
        currentCardSizeValid = false
        collectionView?.collectionViewLayout.invalidateLayout()

        for cell in collectionView.visibleCells {
            if let cardCollectionViewCell = cell as? CardCollectionViewCell {
                cardCollectionViewCell.updateAfterRotateOrResize()
            }
        }
    }
    
    private func matchCards() {
        guard let (oldCard, oldCell) = getFlippedCard(at: 0) else { return }
        guard let (newCard, newCell) = getFlippedCard(at: 1) else { return }

        oldCard.state = .matched
        newCard.state = .matched

        let animator = MatchedCardsAnimator()
        matchedCardsAnimators.append(animator)

        animator.start(oldCell: oldCell, newCell: newCell) { [weak self] in
            self?.matchedCardsAnimators.removeAll { $0 === animator }
            self?.checkCompletion()
        }

        flippedCards.removeAll(keepingCapacity: true)
    }
    
    private func unmatchCards() {
        guard let (oldCard, oldCell) = getFlippedCard(at: 0) else { return }
        guard let (newCard, newCell) = getFlippedCard(at: 1) else { return }

        oldCard.state = .back
        newCard.state = .back

        unmatchedCardsAnimator.start(oldCell: oldCell, newCell: newCell) { [weak self] in
            self?.resetFlippedCards()
        }
    }
    
    private func forceFinishUnmatchCards() {
        guard let (_, oldCell) = getFlippedCard(at: 0) else { return }
        guard let (_, newCell) = getFlippedCard(at: 1) else { return }

        // won't have any effect if no unmatching is currently going on
        unmatchedCardsAnimator.forceFlipToBack(oldCell: oldCell, newCell: newCell)

        resetFlippedCards()
    }
    
    private func getFlippedCard(at index: Int) -> (Card, CardCollectionViewCell)? {
        let (position, card) = flippedCards[index]

        guard let cell = collectionView.cellForItem(
            at: IndexPath(
                item: position,
                section: .zero
            )
        ) as? CardCollectionViewCell else {
            print("Get card error")
            return nil
        }

        return (card, cell)
    }
    
    private func checkCompletion() {
        guard matchedCardsAnimators.isEmpty else { return }

        for card in cards {
            if card.state != .matched && card.state != .complete {
                return
            }
        }
        
        for card in cards {
            card.state = .complete
        }

        completionAnimator.start(cards: cards, collectionView: collectionView)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GameCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if currentCardSizeValid {
            return currentCardSize
        }

        currentCardSize = cardSize.getCardSize(collectionView: collectionView)
        currentCardSizeValid = true
        return currentCardSize
    }
}

@available(iOS 17, *)
#Preview {
    UIStoryboard(name: "Main", bundle: .main)
        .instantiateViewController(withIdentifier: "GameCollectionViewController")
}
