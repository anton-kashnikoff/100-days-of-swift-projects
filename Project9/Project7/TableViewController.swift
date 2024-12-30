//
//  TableViewController.swift
//  Project7
//
//  Created by Антон Кашников on 02.06.2023.
//

import UIKit

final class TableViewController: UITableViewController {
    // MARK: - Private Properties
    private var petitions = [Petition]()
    private var filteredPetitions = [Petition]()

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "White House petitions"

        if #available(iOS 16.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "line.3.horizontal.decrease.circle"), target: self, action: #selector(showFilterAlert))
        } else if #available(iOS 15.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(showFilterAlert))
        } else if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(showFilterAlert))
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "doc.text"), style: .plain, target: self, action: #selector(showCredits))

        let urlString = navigationController?.tabBarItem.tag == 0 ? "https://www.hackingwithswift.com/samples/petitions-1.json" : "https://www.hackingwithswift.com/samples/petitions-2.json"

        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
                self.parce(json: data)
                return
            }

            self.showError()
        }
    }

    // MARK: - Private Methods
    private func parce(json: Data) {
        if let jsonPetitions = try? JSONDecoder().decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteredPetitions = petitions

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            showError()
        }
    }

    private func showError() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }

    private func filterPetitions(by keyword: String) {
        if keyword.isEmpty {
            filteredPetitions = petitions
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "line.3.horizontal.decrease.circle")
            }
            return
        }

        DispatchQueue.main.async {
            if #available(iOS 16.0, *) {
                self.navigationItem.leftBarButtonItem?.title = "Filtered by \"\(keyword)\""
                self.navigationItem.leftBarButtonItem?.image = nil
            }
        }

        filteredPetitions = petitions.filter { petition in
            if let _ = petition.title.range(of: keyword, options: .caseInsensitive) {
                return true
            }
            if let _ = petition.body.range(of: keyword, options: .caseInsensitive) {
                return true
            }
            return false
        }
    }

    @objc private func showFilterAlert() {
        let alertController = UIAlertController(title: "Enter something to filter", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        alertController.addAction(UIAlertAction(title: "Enter", style: .default) { [weak self, weak alertController] _ in
            guard let self, let item = alertController?.textFields?[0].text else {
                return
            }

            DispatchQueue.global().async {
                self.filterPetitions(by: item)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }

    @objc private func showCredits() {
        let alertController = UIAlertController(title: "Credits", message: "The data comes from the We The People API of the Whitehouse.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewController
extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPetitions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = petition.title
            content.secondaryText = petition.body
            content.textProperties.numberOfLines = 1
            content.secondaryTextProperties.numberOfLines = 1
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = petition.title
            cell.detailTextLabel?.text = petition.body
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        detailViewController.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
