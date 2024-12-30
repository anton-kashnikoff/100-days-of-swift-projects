//
//  Capital.swift
//  Project16
//
//  Created by Антон Кашников on 16/12/2023.
//

import MapKit
import UIKit

final class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String

    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
