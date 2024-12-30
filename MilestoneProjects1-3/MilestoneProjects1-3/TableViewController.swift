//
//  TableViewController.swift
//  MilestoneProjects1-3
//
//  Created by Антон Кашников on 22.05.2023.
//

import UIKit

final class TableViewController: UITableViewController {
    // MARK: - Private Properties
    
    private var flags = [String]()

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Country flags"
        
        performSelector(inBackground: #selector(loadImages), with: nil)
    }

    // MARK: - Private Methods
    
    private func getCountryName(for flag: String) -> String {
        flag.replacingOccurrences(of: "flag_", with: "").replacingOccurrences(of: "@3x.png", with: "").uppercased()
    }

    @objc private func loadImages() {
        let items = try! FileManager.default.contentsOfDirectory(atPath: Bundle.main.resourcePath!)
        
        flags = items.filter { item in
            item.hasPrefix("flag")
        }

        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewController

extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        flags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flag", for: indexPath)
        
        guard let flagCell = cell as? FlagCell else { return .init() }
        
        flagCell.countryNameLabel?.text = getCountryName(for: flags[indexPath.row])
        
        flagCell.flagImageView?.image = .init(named: flags[indexPath.row])
        flagCell.flagImageView?.layer.borderColor = UIColor.black.cgColor
        flagCell.flagImageView?.layer.borderWidth = 0.1
        flagCell.flagImageView?.layer.cornerRadius = 5
        
        return flagCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController {
            detailVC.countryName = getCountryName(for: flags[indexPath.row])
            detailVC.flagImage = .init(named: flags[indexPath.row])
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
