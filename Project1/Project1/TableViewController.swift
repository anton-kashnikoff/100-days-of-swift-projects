//
//  TableViewController.swift
//  Project1
//
//  Created by Антон Кашников on 09.02.2023.
//

import UIKit

final class TableViewController: UITableViewController {
    // MARK: - Private Properties
    private var pictures = [String]()
    private var picturesViewsCount = [String: Int]()

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        performSelector(inBackground: #selector(loadImages), with: nil)
    }

    // MARK: - Private Methods
    @objc private func shareTapped() {
        let activityVC = UIActivityViewController(activityItems: ["Hello! This is great app! Try it now!"], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    @objc private func loadImages() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        
        pictures.sort()
        
        picturesViewsCount = UserDefaults.standard.object(forKey: "ViewsCount") as? [String: Int] ?? [String: Int]()

        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewController
extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = pictures[indexPath.row]
            content.secondaryText = "Views count: \(picturesViewsCount[pictures[indexPath.row], default: 0])"
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = pictures[indexPath.row]
            cell.detailTextLabel?.text = "Views count: \(picturesViewsCount[pictures[indexPath.row], default: 0])"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            detailViewController.selectedImage = pictures[indexPath.row]
            detailViewController.selectedPictureNumber = indexPath.row + 1
            detailViewController.totalPictures = pictures.count
            
            picturesViewsCount[pictures[indexPath.row], default: 0] += 1
            
            DispatchQueue.global().async { [weak self] in
                UserDefaults.standard.set(self?.picturesViewsCount, forKey: "ViewsCount")
                
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(detailViewController, animated: true)
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
