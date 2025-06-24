//
//  SettingsViewController.swift
//  MilestoneProjects28-30
//
//  Created by Антон Кашников on 23/06/2025.
//

import UIKit

protocol SettingsDelegate {
    func settings(_ settings: SettingsViewController, didUpdateCards cards: String)
    func settings(
        _ settings: SettingsViewController,
        didUpdateGrid grid: Int,
        didUpdateGridElement gridElement: Int
    )
}

final class SettingsViewController: UIViewController {
    private let cardsDirectory = "Cards.bundle/"
    
    @IBOutlet private var cardsTableView: UITableView!
    @IBOutlet private var gridSizeTableView: UITableView!
    
    private var cards: [String]!
    private var currentCards: String!
    private var currentGrid: Int!
    private var currentGridElement: Int!
    
    private var isParametersSet: Bool {
        currentCards != nil && currentGrid != nil && currentGridElement != nil
    }
    
    var delegate: SettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard isParametersSet else { fatalError("Parameters not provided") }
        
        navigationItem.largeTitleDisplayMode = .never
        title = "Settings"
        
        loadCards()
        
        cardsTableView.delegate = self
        cardsTableView.dataSource = self
        selectCurrentCard()
        
        gridSizeTableView.delegate = self
        gridSizeTableView.dataSource = self
        selectCurrentGrid()
    }
    
    private func loadCards() {
        guard let urls = Bundle.main.urls(
            forResourcesWithExtension: nil,
            subdirectory: cardsDirectory
        ) else { return }
        
        cards = [String]()
        
        for url in urls {
            cards.append(url.lastPathComponent)
        }
        
        cards.sort()
    }
    
    private func selectCurrentCard() {
        guard let index = cards.firstIndex(of: currentCards) else { return }
        let indexPath = IndexPath(row: index, section: .zero)
        cardsTableView.selectRow(
            at: indexPath,
            animated: true,
            scrollPosition: .none
        )
        
        cardsTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    private func selectCurrentGrid() {
        let indexPath = IndexPath(row: currentGridElement, section: currentGrid)
        gridSizeTableView.selectRow(
            at: indexPath,
            animated: true,
            scrollPosition: .none
        )
        
        gridSizeTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    func setParameters(
        currentCards: String,
        currentGrid: Int,
        currentGridElement: Int
    ) {
        self.currentCards = currentCards
        self.currentGrid = currentGrid
        self.currentGridElement = currentGridElement
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cardsTableView {
            delegate?.settings(self, didUpdateCards: cards[indexPath.row])
        } else {
            delegate?.settings(
                self,
                didUpdateGrid: indexPath.section,
                didUpdateGridElement: indexPath.row
            )
        }
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if tableView == cardsTableView {
            return cards.count
        }

        return grids[section].combinations.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if tableView == cardsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

            if #available(iOS 14, *) {
                var contentConfiguration = cell.defaultContentConfiguration()
                contentConfiguration.text = cards[indexPath.row]
                cell.contentConfiguration = contentConfiguration
            } else {
                cell.textLabel?.text = cards[indexPath.row]
            }

            return cell
        }

        let (gridSide1, gridSide2) = grids[indexPath.section].combinations[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if #available(iOS 14, *) {
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = "\(gridSide1) x \(gridSide2)"
            cell.contentConfiguration = contentConfiguration
        } else {
            cell.textLabel?.text = "\(gridSide1) x \(gridSide2)"
        }

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == cardsTableView {
            return 1
        }

        return grids.count
    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        if tableView == cardsTableView {
            return String()
        }

        return "Cards: \(grids[section].numberOfElements)"
    }
}

@available(iOS 17, *)
#Preview {
    let settingsViewController = UIStoryboard(
        name: "Settings",
        bundle: .main
    ).instantiateViewController(
        withIdentifier: "SettingsViewController"
    ) as! SettingsViewController
    
    settingsViewController.setParameters(
        currentCards: "Characters",
        currentGrid: 4,
        currentGridElement: 1
    )
    
    return settingsViewController
}
