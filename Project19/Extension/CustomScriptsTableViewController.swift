//
//  CustomScriptsTableViewController.swift
//  Extension
//
//  Created by Антон Кашников on 12/01/2024.
//

import UIKit

protocol CustomScriptsDataDelegate {
    var customScripts: [CustomScript] { get }
    func setScriptToShow(at index: Int)
}

final class CustomScriptsTableViewController: UITableViewController {
    // MARK: - Public Properties
    
    var delegate: CustomScriptsDataDelegate?

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        delegate?.customScripts.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customScriptCell", for: indexPath)
        
        if #available(iOSApplicationExtension 14.0, *) {
            var configuration = cell.defaultContentConfiguration()
            configuration.text = delegate?.customScripts[indexPath.row].name
            cell.contentConfiguration = configuration
        } else {
            cell.textLabel?.text = delegate?.customScripts[indexPath.row].name
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.setScriptToShow(at: indexPath.row)
        navigationController?.popViewController(animated: true)
    }
}
