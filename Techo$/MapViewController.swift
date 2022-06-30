//
//  MapViewController.swift
//  Techo$
//
//  Created by Yue Yan on 18/5/2022.
//
/*
  Similar reference/sources were used here as to ReportMapViewController.swift
 */

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedMarker = placemark
        
        // clear existing annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // create new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    var selectedMarker: MKPlacemark?
    var addLocationDelegate: AddLocationDelegate?
    
    var resultSearchController:UISearchController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialise map
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // set up search controller
        let controller = storyboard!.instantiateViewController(withIdentifier: "locationSearchTable") as! LocationsTableViewController
        resultSearchController = UISearchController(searchResultsController: controller)
        resultSearchController?.searchResultsUpdater = controller
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.searchController = resultSearchController
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        controller.mapView = mapView
        controller.handleMapSearchDelegate = self
        
        setupNavigationBar()
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    @IBAction func selectLocation(sender: AnyObject) {
        guard selectedMarker != nil else{
            displayMessage(title: "No Markers", message: "Please select a location!")
            return
        }
        let alert = UIAlertController(title: "Do you want to select this location?", message: "\(String(describing: selectedMarker!.name!))", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default , handler:{ [self] (UIAlertAction) in
            let location = LocationAnnotation(title: selectedMarker!.name!, subtitle: parseAddress(selectedItem: selectedMarker!), coordinates: selectedMarker!.coordinate)
            
            addLocationDelegate?.addLocation(location: location)
            navigationController?.popViewController(animated: true)
        }))
            
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))


        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
                locationManager.requestLocation()
            }
        }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
    
    func focusOn(annotation: MKAnnotation){
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }
}
