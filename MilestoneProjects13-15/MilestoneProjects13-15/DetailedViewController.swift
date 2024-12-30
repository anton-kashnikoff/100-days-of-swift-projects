//
//  DetailedViewController.swift
//  MilestoneProjects13-15
//
//  Created by Антон Кашников on 18/11/2023.
//

import UIKit

final class DetailedViewController: UIViewController {
    @IBOutlet private var regionLabel: UILabel!
    @IBOutlet private var areaLabel: UILabel!
    @IBOutlet private var capitalLabel: UILabel!
    @IBOutlet private var populationLabel: UILabel!
    @IBOutlet private var flagImageView: UIImageView!
    @IBOutlet private var currenciesLabel: UILabel!
    
    var countryTitle = ""
    var region = ""
    var area = ""
    var capital = ""
    var population = ""
    var flagURL = ""
    var currencies = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareInfo))
        
        title = countryTitle
        regionLabel.text = region
        areaLabel.text = area
        capitalLabel.text = capital
        populationLabel.text = population
        currenciesLabel.text = currencies
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if
                let url = URL(string: self?.flagURL ?? ""),
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            {
                DispatchQueue.main.async {
                    self?.flagImageView.image = image
                }
            }
        }
    }
    
    @objc
    private func shareInfo() {
        guard let image = flagImageView.image else { return }
        let info = "Country: \(countryTitle),\nRegion: \(region),\nArea: \(area),\nCapital: \(capital),\nPopulation: \(population),\nCurrency: \(currencies)"
        let activityViewController = UIActivityViewController(activityItems: [image, info], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
}
