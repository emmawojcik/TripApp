
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    enum PlaceOfInterestType: String, CaseIterable {
        case restaurant = "Restaurant"
        case hotel = "Hotel"
        case entertainment = "Entertainment"
        case bar = "Bar"
        case museum = "Museum"
        case shop = "Shop"
        case none = "None"
    }
    
    @IBAction func filterWasTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)
        for type in PlaceOfInterestType.allCases {
            alertController.addAction(UIAlertAction(title: type.rawValue, style: .default, handler: { (_) in
                self.filterType = type
                self.mapView.removeAnnotations(self.placeOfInterestAnnotations)
                self.placeOfInterestAnnotations = []
                self.searchMapItems = []
                self.searchItemMapping = [:]
                self.searchArea()
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    private let placesApi: PlacesApi = PlacesApi ()
    var filterType: PlaceOfInterestType = .none
    var trip: TripResponse!
    var events: [EventResponse]!
    var placeOfInterestAnnotations: [MKPointAnnotation] = []
    var eventAnnotations: [MKPointAnnotation] = []
    var eventMapping: [MKPointAnnotation: EventResponse] = [:]
    var searchItemMapping: [MKPointAnnotation: SearchMapItem] = [:]
    var selectedEvent: EventResponse?
    var searchMapItems: [SearchMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.register(PlaceOfInterestAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PlaceOfInterestAnnotation")
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        plotMapAnnotations()
    }
    
    // plot user's planned events
    func plotMapAnnotations() {
        var annotations: [MKPointAnnotation] = []
        
        for event in events {
            let place = MKPointAnnotation()            
            place.title = event.name
            place.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(event.latitude), longitude: CLLocationDegrees(event.longitude))
            annotations.append(place)
            self.mapView.addAnnotation(place)
            eventMapping[place] = event
        }
        eventAnnotations = annotations
        self.mapView.showAnnotations(annotations, animated: false)
    }
    
    // update the annotations if current region is changed
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        searchArea()
    }
    
    // add place of interest annotations
    func searchArea() {
        guard filterType != .none else {
            return
        }
        let region = mapView.region
        let location = region.center
        placesApi.searchMap(location: location, radius: Int(mapView.currentRadius()), type: filterType.rawValue) { (items) in
            print(self.filterType.rawValue)
            for item in items {
                let place = MKPointAnnotation()
                place.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(item.latitude), longitude: CLLocationDegrees(item.longitude))
                self.placeOfInterestAnnotations.append(place)
                self.searchItemMapping[place] = item
            }
            self.searchMapItems.append(contentsOf: items)
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.placeOfInterestAnnotations)
            }
        }
    }
    
    // segue to event page if event annotation is clicked
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? MKPointAnnotation, let selectedEvent = eventMapping[annotation] else {
            return
        }
        self.selectedEvent = selectedEvent
        performSegue(withIdentifier: "ShowEvent", sender: self)
    }
    
    // make detail view for place of interest pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation, placeOfInterestAnnotations.contains(annotation), let searchMapItem = searchItemMapping[annotation] else {
            return nil
        }
        let pin = mapView.dequeueReusableAnnotationView(withIdentifier: "PlaceOfInterestAnnotation", for: annotation)
        // custom pin image obtained from http://www.icons-land.com/flat-mapmarkers-png-icons.php
        pin.image = #imageLiteral(resourceName: "poi_pin")
        pin.canShowCallout = true
        let detailView = PlaceOfInterestDetailView.make()
        detailView.customise(searchMapItem: searchMapItem)
        pin.detailCalloutAccessoryView = detailView
        return pin
    }
    
    // provide event view controller with the selected event
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? EventViewController, let selectedEvent = selectedEvent {
            viewController.event = selectedEvent
        }
    }
}

extension MKMapView {

    func topCenterCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }
    
    // get distance between top centre coordinate and centre coordinate (the radius)
    func currentRadius() -> Double {
        let centerLocation = CLLocation(latitude: self.centerCoordinate.latitude, longitude: self.centerCoordinate.longitude)
        let topCenterCoordinate = self.topCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        return centerLocation.distance(from: topCenterLocation)
    }

}
