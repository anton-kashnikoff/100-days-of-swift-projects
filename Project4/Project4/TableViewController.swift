//
//  TableViewController.swift
//  Project4
//
//  Created by Антон Кашников on 26.05.2023.
//

import UIKit

final class TableViewController: UITableViewController {
    // MARK: - Private Properties
    private var websites = ["kodeco.com", "hackingwithswift.com"]

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Websites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - UITableViewController
extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        websites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebSite", for: indexPath)
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = websites[indexPath.row]
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = websites[indexPath.row]
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let webViewViewController = storyboard?.instantiateViewController(identifier: "WebView") as? WebViewController {
            webViewViewController.selectedWebSite = websites[indexPath.row]
            webViewViewController.availableWebsites = websites
            navigationController?.pushViewController(webViewViewController, animated: true)
        }
    }
}
