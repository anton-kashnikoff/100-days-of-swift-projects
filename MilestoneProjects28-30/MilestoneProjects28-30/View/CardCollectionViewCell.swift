//
//  CardCollectionViewCell.swift
//  MilestoneProjects28-30
//
//  Created by Антон Кашников on 23/06/2025.
//

import UIKit

final class CardCollectionViewCell: UICollectionViewCell {
    private var frontImageView: UIImageView!
    private var backImageView: UIImageView!

    private var card: Card?
    
    private var facingSide: CardState {
        backImageView.isHidden ? .front : .back
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }
    
    private func build() {
        frontImageView = UIImageView(
            frame: CGRect(
                x: .zero,
                y: .zero,
                width: frame.size.width,
                height: frame.size.height
            )
        )
        
        frontImageView.contentMode = .scaleAspectFit
        frontImageView.isHidden = true

        backImageView = UIImageView(
            frame: CGRect(
                x: .zero,
                y: .zero,
                width: frame.size.width,
                height: frame.size.height
            )
        )
        
        backImageView.contentMode = .scaleAspectFit

        addSubview(frontImageView)
        addSubview(backImageView)
    }
    
    private func reset(state: CardState) {
        // cells are reused by the collection view, make sure to clean everything
        cancelAnimations()

        updateImagesSize()

        // reset card position
        let (flipTarget, scaleFactor): (CardState, CGFloat) = switch state {
        case .back: (.back, 1)
        case .front: (.front, 1)
        case .matched: (.front, 0.6)
        case .complete: (.front, 1)
        }

        animateFlipTo(state: flipTarget)
        DispatchQueue.main.async { [weak self] in
            self?.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        }
    }
    
    private func cancelAnimations() {
        layer.removeAllAnimations()
        frontImageView.layer.removeAllAnimations()
        backImageView.layer.removeAllAnimations()
    }
    
    private func updateImagesSize() {
        frontImageView.frame = CGRect(
            x: .zero,
            y: .zero,
            width: frame.size.width,
            height: frame.size.height
        )
        
        backImageView.frame = CGRect(
            x: .zero,
            y: .zero,
            width: frame.size.width,
            height: frame.size.height
        )
    }
    
    func set(card: Card) {
        self.card = card
        frontImageView.image = UIImage(named: card.frontImage)
        backImageView.image = UIImage(named: card.backImage)

        reset(state: card.state)
    }
    
    func updateAfterRotateOrResize() {
        DispatchQueue.main.async { [weak self] in
            self?.updateImagesSize()
        }

        if card?.state == .matched {
            // async allows scale animation to continue if in progress
            DispatchQueue.main.async { [weak self] in
                self?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            }
        }
    }
    
    func animateCompleteGame() {
        transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    func animateMatch() {
        transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }
    
    func animateFlipTo(state: CardState) {
        guard state == .front || state == .back else {
            fatalError("Can only flip to front or back")
        }

        let from, to: UIView
        let transition: AnimationOptions

        if state == .front {
            guard facingSide == .back else { return }
            from = backImageView
            to = frontImageView
            transition = .transitionFlipFromRight
        } else {
            guard facingSide == .front else { return }
            from = frontImageView
            to = backImageView
            transition = .transitionFlipFromLeft
        }

        UIView.transition(
            from: from,
            to: to,
            duration: .zero,
            options: [transition, .showHideTransitionViews]
        )
    }
}
