//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

final class SelectionViewController: UITableViewController {
	private var items = [String]() // this is the array that will store the filenames to load
    
	var dirty = false
    
    var images = [UIImage?]()
    var finishedLoadingImages = false

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none
        
        if #available(iOS 14, *) {
            tableView.register(ShadowImageCell.self, forCellReuseIdentifier: "ShadowImageCell")
        } else {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        }
        
        DispatchQueue.global().async { [weak self] in
            self?.loadImages()
        }
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !finishedLoadingImages {
            return .zero
        }
        
        return items.count * 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row % items.count
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
        let image = images[index]
        let key = items[index]
        
        // each image stores how often it's been tapped
        if #available(iOS 14, *) {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ShadowImageCell",
                for: indexPath
            ) as? ShadowImageCell else {
                return createStandardCell(
                    for: tableView,
                    at: indexPath,
                    with: image,
                    and: key,
                    in: renderRect
                )
            }
            
            cell.configure(
                with: image,
                text: "\(UserDefaults.standard.integer(forKey: key))"
            )
            
            return cell
        } else {
            return createStandardCell(
                for: tableView,
                at: indexPath,
                with: image,
                and: key,
                in: renderRect
            )
        }
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let imageViewController = ImageViewController()
		imageViewController.image = items[indexPath.row % items.count]
		imageViewController.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false

		navigationController?.pushViewController(imageViewController, animated: true)
	}
    
    private func loadImages() {
        // load all the JPEGs into our array
        guard let resourcePath = Bundle.main.resourcePath,
              let tempItems = try? FileManager.default.contentsOfDirectory(atPath: resourcePath)
        else { return }
        
        tempItems.forEach { item in
            if item.range(of: "Large") != nil {
                items.append(item)
                
                let path: String
                let documentDirectory = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                ).first
                
                // try to load from cache
                if #available(iOS 16, *) {
                    guard let url = documentDirectory?.appending(path: item) else {
                        return
                    }
                    
                    path = url.path()
                } else {
                    guard let url = documentDirectory?.appendingPathComponent(item) else {
                        return
                    }
                    
                    path = url.path
                }
                
                if let image = UIImage(contentsOfFile: path) {
                    images.append(image)
                } else {
                    images.append(createThumbnail(from: item))
                }
            }
        }
        
        finishedLoadingImages = true
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func createThumbnail(from imageName: String) -> UIImage {
        // find the image for this cell, and load its thumbnail
        let imageRootName = imageName.replacingOccurrences(of: "Large", with: "Thumb")
        let path = Bundle.main.path(forResource: imageRootName, ofType: nil)!
        let originalImage = UIImage(contentsOfFile: path)!

        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))

        let roundedImage = UIGraphicsImageRenderer(
            size: renderRect.size
        ).image { context in
            context.cgContext.addEllipse(in: renderRect)
            context.cgContext.clip()

            originalImage.draw(in: renderRect)
        }
        
        saveToCache(name: imageName, image: roundedImage)
        
        return roundedImage
    }
    
    private func saveToCache(name: String, image: UIImage) {
        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        
        let imagePath = if #available(iOS 16, *) {
            documentDirectory?.appending(path: name)
        } else {
            documentDirectory?.appendingPathComponent(name)
        }
        
        guard let imagePath else { return }
        
        if let pngData = image.pngData() {
            try? pngData.write(to: imagePath)
        }
    }
    
    private func createStandardCell(
        for tableView: UITableView,
        at indexPath: IndexPath,
        with roundedImage: UIImage?,
        and currentImage: String,
        in renderRect: CGRect
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView?.image = roundedImage
    
        // give the images a nice shadow to make them look a bit more dramatic
        cell.imageView?.layer.shadowColor = UIColor.black.cgColor
        cell.imageView?.layer.shadowOpacity = 1
        cell.imageView?.layer.shadowRadius = 10
        cell.imageView?.layer.shadowOffset = .zero
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath
        
        cell.textLabel?.text = "\(UserDefaults.standard.integer(forKey: currentImage))"
        return cell
    }
}

@available(iOS 17, *)
#Preview {
    SelectionViewController(style: .plain)
}
