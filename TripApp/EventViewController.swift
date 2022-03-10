
import UIKit
import MapKit

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum Cell {
        case image(UIImage?)
        case title(String)
        case address(String)
        case phoneNumber(String)
        case website(String)
        case openingHours(String)
        case map(Float, Float, String)
    }
    
    var event: EventResponse!
    var trip: TripResponse!
    
    private let placesApi: PlacesApi = PlacesApi ()
    private let eventsManager: EventsManager = EventsManager()
    private var placeDetailsArray: [PlaceDetails] = []
    private var placeDetailsDictionary = [String: PlaceDetails]()
    private var cells: [Cell] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    private weak var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cells = [.image(nil)]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        fetchPlaceDetails()        
    }
    
    func fetchPlaceDetails () {
        placesApi.getPlaceDetails(placeIdentifier: event.place_identifier, completion: { (placeDetails) in
            // check if any place details were retrieved, otherwise cells are empty
            guard let placeDetails = placeDetails else {
                self.cells = []
                return
            }
            // append title and address since they are guaranteed to exist
            self.cells = [
                .title(placeDetails.name),
                .address(placeDetails.address),
            ]
            // if a phone number exists for an event, append it to array of cells
            if let phoneNumber = placeDetails.phoneNumber {
                self.cells.append(.phoneNumber(phoneNumber))
            }
            // if a website exists for an event, append it to array of cells
            if let website = placeDetails.website {
                self.cells.append(.website(website))
            }
            // if opening hours exist for an event, append it to array of cells
            if let openingHours = placeDetails.openingHours {
                // convert opening hours into readable format
                let openingHoursString = openingHours.joined(separator: "\n")
                self.cells.append(.openingHours(openingHoursString))
            }
            self.cells.append(.map(placeDetails.latitude, placeDetails.longitude, placeDetails.name))
            
            DispatchQueue.main.async {
                if let imageView = self.imageView, let photoReference = placeDetails.photoReference {
                    // retrieve image for event
                    self.placesApi.getPlaceImage(photoReference: photoReference, maxHeight: Int(imageView.bounds.height)) { (image) in
                        self.cells.insert(.image(image), at: 0)
                    }
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cells[indexPath.row]
        
        // layout cell according to what place details data it should display
        switch cell {
        case .image(let image):
            let imageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageTableViewCell
            imageTableViewCell.backgroundImageView.image = image
            self.imageView = imageTableViewCell.backgroundImageView
            return imageTableViewCell
            
        case .title(let title):
            let titleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleTableViewCell
            titleTableViewCell.titleLabel.text = title
            return titleTableViewCell
            
        case .address(let address):
            let addressTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as! AddressTableViewCell
            addressTableViewCell.addressLabel.text = address
            return addressTableViewCell
            
        case .phoneNumber(let phoneNumber):
            let phoneNumberTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PhoneNumberCell", for: indexPath) as! PhoneNumberTableViewCell
            phoneNumberTableViewCell.phoneNumberLabel.text = phoneNumber
            return phoneNumberTableViewCell
            
        case .website(let website):
            let websiteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WebsiteCell", for: indexPath) as! WebsiteTableViewCell
            websiteTableViewCell.websiteLabel.text = website
            return websiteTableViewCell
            
        case .openingHours(let openingHours):
            let openingHoursTableViewCell = tableView.dequeueReusableCell(withIdentifier: "OpeningHoursCell", for: indexPath) as! OpeningHoursTableViewCell
            openingHoursTableViewCell.openingHoursLabel.text = openingHours
            return openingHoursTableViewCell
            
        case .map(let latitude, let longitude, let name):
            let mapTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath) as! MapTableViewCell
            let initialLocation = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            
            let place = MKPointAnnotation()
            place.title = name
            place.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            mapTableViewCell.mapView.addAnnotation(place)
            mapTableViewCell.mapView.setRegion(coordinateRegion, animated: true)
            
            return mapTableViewCell
        }
    }
    
    // edit menu options
    func showEventActionSheet(controller: UIViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Delete Event", style: .destructive, handler: { (_) in
            let deleteAlert = UIAlertController(title: "Are you sure you want to delete the event?", message: nil, preferredStyle: .actionSheet)
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                self.eventsManager.delete(id: self.event.id) { (successful) in
                    print(successful)
                }
                self.performSegue(withIdentifier: "EventToItinerary", sender: self)
            }))
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(deleteAlert, animated: true, completion: nil)
            print("Delete button")
        }))

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("Dismiss button")
        }))

        self.present(alert, animated: true, completion: {
            print("completion")
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let itineraryViewController = segue.destination as! ItineraryViewController
        itineraryViewController.trip = self.trip
    }
    
    // if cells are clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cells[indexPath.row] {
        case .phoneNumber(let phoneNumber):
            let formattedNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
            if let url = URL(string: "tel://" + formattedNumber) {
                UIApplication.shared.open(url)
            } 
        case .website(let website):
            if let url = URL(string: website) {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }
    
    @IBAction func editEvent(_ sender: Any) {
        showEventActionSheet(controller: self)
    }
    
}
