//
//  CountriesViewController.swift
//  MilestoneProjects13-15
//
//  Created by Антон Кашников on 18/11/2023.
//

import UIKit

final class CountriesViewController: UITableViewController {
    private var countries: [Country]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "https://restcountries.com/v3.1/all"
        
        DispatchQueue.global(qos: .userInitiated).async {
            if
                let url = URL(string: urlString),
                let data = try? Data(contentsOf: url)
            {
                self.parce(json: data)
                return
            }
            
            self.showError()
        }
        
        title = "Countries"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "countryCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailed" {
            if
                let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell),
                let detailedViewController = segue.destination as? DetailedViewController,
                let countries
            {
                detailedViewController.countryTitle = countries[indexPath.row].name.official
                detailedViewController.region = countries[indexPath.row].region
                detailedViewController.area = "\(String(describing: countries[indexPath.row].area))"
                detailedViewController.capital = countries[indexPath.row].capital?[0] ?? ""
                detailedViewController.population = "\(String(describing: countries[indexPath.row].population))"
                detailedViewController.flagURL = countries[indexPath.row].flags?.png ?? ""
                detailedViewController.currencies = countries[indexPath.row].currencies?.values.first?.name ?? ""
            }
        }
    }
    
    private func parce(json: Data) {
        if let jsonCountries = try? JSONDecoder().decode([Country].self, from: json) {
            countries = jsonCountries
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            showError()
        }
    }
    
    private func showError() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: "Loading error",
                message: "There was a problem loading the feed; please check your connection and try again.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension CountriesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = if let flag = countries?[indexPath.row].flag {
                "\(flag) \(countries?[indexPath.row].name.official ?? "")"
            } else {
                countries?[indexPath.row].name.official
            }
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = countries?[indexPath.row].name.official
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CountriesViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "showDetailed", sender: cell)
    }
}
