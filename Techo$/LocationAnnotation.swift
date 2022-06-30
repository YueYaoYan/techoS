//
//  LocationAnnotation.swift
//  Techo$
//
//  Created by Yue Yan on 24/5/2022.
//

import Foundation
import MapKit

class LocationAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String, lat: Double, long: Double) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    init(title: String, subtitle: String, coordinates: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinates
    }
    
}

protocol NewLocationDelegate: NSObject {
    func annotationAdded(annotation: LocationAnnotation)
}
