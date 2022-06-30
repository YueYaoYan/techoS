//
//  ReportMapViewController.swift
//  Techo$
//
//  Created by Yue Yan on 18/5/2022.
//
/*
 These following tutorials and fourm discussion was accessed and assisted the completion of varies functions within this file:
    Codes was used as references and clarify concepts only:
     - https://developer.apple.com/documentation/mapkit/mkannotationview/decluttering_a_map_with_mapkit_annotation_clustering
    - https://developer.apple.com/documentation/mapkit/mkmapviewdelegate/1451897-mapviewdidfinishrenderingmap
    
    Code was used and moderate amount of modifications were done
     - http://infinityjames.com/blog/mapkit-ios11
     - https://medium.com/@worthbak/clustering-with-mapkit-on-ios-11-part-2-2418a865543b
     - https://stackoverflow.com/questions/39747957/mapview-to-show-all-annotations-and-zoom-in-as-much-as-possible-of-the-map
 */
//

import UIKit
import MapKit

/**
 View Controller displaying filtered transactions' location on map from mapkit
 */
class ReportMapViewController: UIViewController, CLLocationManagerDelegate, DatabaseListener, MKMapViewDelegate{
    
    //  MARK: Properties for mapkit
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    var selectedMarker: MKPlacemark?
    
    // MARK: Properties for database
    var databaseController: DatabaseProtocol?
    var allTransactions: [Transaction] = []
    var filteredTrans: [Transaction] = []
    var listenerType = ListenerType.transaction
    var firstLoad = true
    
    func onAllCategoriesChange(change: DatabaseChange, categories: [Category]) {
        
    }
    
    func onAllTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        let function = databaseController?.currentFilter ?? FilterGroup()
        
        allTransactions = transactions
        filteredTrans = allTransactions.filter({(trans: Transaction) -> Bool in
            return (trans.location != nil) && function.filter(transaction: trans)
        })
        addAnnotations()
    }
    
    func onAllAccountsChange(change: DatabaseChange, accounts: [Account]) {
        
    }
    
    func onAllEventsChange(change: DatabaseChange, events: [Event]) {
        
    }
    
    func onAllGoalsChange(change: DatabaseChange, goals: [Goal]) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialise database
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // initialise mapkit
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        
        // register for cluster view
        mapView.register(ReportAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func addAnnotations(){
        // clear existing annotations
        mapView.removeAnnotations(mapView.annotations)
        
        
        // add annotation for locations
        filteredTrans.forEach{trans in
            guard let loc = trans.location, let name = loc.name, let amount = trans.amount, let isSpending = trans.isSpending else{
                return
            }
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(loc.lat!), CLLocationDegrees(loc.lon!))
            
            // create new annotation
            let annotation = ReportAnnotation(coordinate: coordinate, name: name, amount: amount, isSpending: isSpending)
            
            mapView.addAnnotation(annotation)
        }
        fitAll()
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool){
        databaseController?.addListener(listener: self)
        mapView.delegate = nil
    }

    func fitAll() {
        var zoomRect = MKMapRect.null;
        for annotation in mapView.annotations {
            // add point rect to zoomrect
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.5, height: 0.5)
            zoomRect = zoomRect.union(pointRect)
        }
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 200, left: 200, bottom: 200, right: 200), animated: true)
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
        }else{
            fitAll()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
}

public class ReportAnnotation: NSObject, MKAnnotation {
    //  MARK: Properties
    public let name: String
    public let amount: Double
    public let coordinate: CLLocationCoordinate2D
    public let isSpending: Bool

    //  MARK: Initialization
    public init(coordinate: CLLocationCoordinate2D, name: String, amount: Double, isSpending: Bool) {
        self.name = name
        self.coordinate = coordinate
        self.amount = amount
        self.isSpending = isSpending
    }
    
    public var title: String? { return amount.formatCurrency() }
    public var subtitle: String? { return name}
}


internal final class ReportAnnotationView: MKMarkerAnnotationView {
    //  MARK: Properties
    internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }
    
    // Configurate annotation marker
    func configure(with annotation: MKAnnotation) {
        guard annotation is ReportAnnotation else { fatalError("Unexpected annotation type: \(annotation)") }
        let anno = annotation as! ReportAnnotation
        if anno.isSpending{
            markerTintColor = .red
            glyphImage = UIImage(systemName: "minus")
        }else{
            markerTintColor = .green
            glyphImage = UIImage(systemName: "plus")
        }
        
        clusteringIdentifier = "Report"
    }
}

internal final class ClusterView: MKAnnotationView {
    //  MARK: Properties
    internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }
    
    //  MARK: Initialization
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
        centerOffset = CGPoint(x: 0.0, y: -10.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) not implemented.")
    }

    //  MARK: Configuration
    func configure(with annotation: MKAnnotation) {
        guard let annotation = annotation as? MKClusterAnnotation else { return }
        displayPriority = .defaultHigh
        
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        image = ReportGraphicImageRender.image(for: annotation.memberAnnotations, in: rect)
    }
}

class ReportGraphicImageRender: UIGraphicsImageRenderer {
    static func image(for annotations: [MKAnnotation], in rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        
        let totalCount = annotations.count
        let spendCount = annotations.spendCount
        
        let countText = "\(totalCount)"
        
        return renderer.image { _ in
            // set colour for owning
            UIColor.green.setFill()
            UIBezierPath(ovalIn: rect).fill()
            
            // set colour for spending
            UIColor.red.setFill()
            
            // create ratio pie for cluster
            let piePath = UIBezierPath()
            piePath.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 20,
                           startAngle: 0, endAngle: (CGFloat.pi * 2.0 * CGFloat(spendCount)) / CGFloat(totalCount),
                           clockwise: true)
            piePath.addLine(to: CGPoint(x: 20, y: 20))
            piePath.close()
            piePath.fill()
            
            // colour for inner pie
            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 24, height: 24)).fill()
            
            countText.drawForCluster(in: rect)
        }
    }
}

//  MARK: Additional functions used to support cluster marker implementation
extension Sequence where Element == MKAnnotation {
    var spendCount: Int {
        return self
            .compactMap { $0 as? ReportAnnotation }
            .filter { $0.isSpending }
            .count
    }
}

extension String {
    func drawForCluster(in rect: CGRect) {
        let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                           NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]
        let textSize = self.size(withAttributes: attributes)
        let textRect = CGRect(x: (rect.width / 2) - (textSize.width / 2),
                              y: (rect.height / 2) - (textSize.height / 2),
                              width: textSize.width,
                              height: textSize.height)
        
        self.draw(in: textRect, withAttributes: attributes)
    }
}
