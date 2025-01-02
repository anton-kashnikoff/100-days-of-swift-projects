//
//  TableViewController.swift
//  MilestoneProjects4-6
//
//  Created by Антон Кашников on 31.05.2023.
//

import UIKit

final class TableViewController: UITableViewController {
    // MARK: - Private Properties
    
    private var shoppingList = [String]()

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        addNavigationBar()
    }

    // MARK: - Private Methods
    
    @objc private func promptForItem() {
        let alertController = UIAlertController(title: "Enter an item", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let submitAlertAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alertController] _ in
            guard let item = alertController?.textFields?.first?.text else {
                return
            }
            
            self?.submit(item)
        }

        alertController.addAction(submitAlertAction)
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    @objc private func clearBarButtonTapped() {
        shoppingList = []
        tableView.reloadData()
    }

    @objc private func shareBarButtonTapped() {
        let activityViewController = UIActivityViewController(activityItems: [shoppingList.joined(separator: "\n")], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    private func submit(_ item: String) {
        shoppingList.insert(item, at: .zero)
        tableView.insertRows(at: [.init(row: .zero, section: .zero)], with: .automatic)
    }
    
    private func addNavigationBar() {
        title = "Shopping list"
        navigationController?.navigationBar.prefersLargeTitles = true

        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForItem))
        let clearBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearBarButtonTapped))
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareBarButtonTapped))
        navigationItem.leftBarButtonItem = clearBarButtonItem
        navigationItem.rightBarButtonItems = [shareBarButtonItem, addBarButtonItem]
    }
}

// MARK: - UITableViewController

extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = shoppingList[indexPath.row]
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = shoppingList[indexPath.row]
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shoppingList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
