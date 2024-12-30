//
//  Person.swift
//  Project10
//
//  Created by Антон Кашников on 14.06.2023.
//

import Foundation

class Person: NSObject, NSCoding {
    // MARK: - Public Properties
    var name: String
    var image: String

    // MARK: - Initializers
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }

    // MARK: - NSCoding
    required init(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") as? String ?? ""
        image = coder.decodeObject(forKey: "image") as? String ?? ""
    }

    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(image, forKey: "image")
    }
}
