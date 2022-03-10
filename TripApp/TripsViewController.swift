
import UIKit

struct TripResponse: Decodable {
    let name: String
    let start_date: String
    let end_date: String
    let id: Int
    let place_identifier: String
    let photo_reference: String
}


class TripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tripAppApi = TripAppApi()
    private let placesApi: PlacesApi = PlacesApi ()
    private let tripsManager = TripsManager()
    private let credentialsStore: CredentialsStore = CredentialsStore()
    private var allTrips: [[TripResponse]] = []
    private var selectedIndexPath: IndexPath?
    private var tripImages: [UIImage] = []
    private weak var imageView: UIImageView?
    
    @IBOutlet weak var tripTableView: UITableView!
    
    // when screen is first loaded from storyboard
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTrips()
        tripTableView.reloadData()
        tripTableView.delegate = self
        tripTableView.dataSource = self
    }
    
    // every time the screen appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        allTrips.removeAll()
        fetchTrips()
    }
    
    // return number of sections (number of trips)
    func numberOfSections(in tableView: UITableView) -> Int {
        return allTrips.count
    }
    
    // return number of rows (each trip has its own section)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTrips[section].count
    }
    
    // create visual representation of cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // format dates into readable format
        var startDateString: String = ""
        var endDateString: String = ""
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatterGet.timeZone = TimeZone(secondsFromGMT: 0)

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE d MMMM"
        
        let trip = allTrips[indexPath.section][indexPath.row]

        if let startDateToFormat = dateFormatterGet.date(from: trip.start_date) {
            startDateString = dateFormatterPrint.string(from: startDateToFormat)
        } else {
           print("Unable to decode the string")
        }
        if let endDateToFormat = dateFormatterGet.date(from: trip.end_date) {
            endDateString = dateFormatterPrint.string(from: endDateToFormat)
        } else {
            print("Unable to decode the string")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! CustomTripCell

        placesApi.getPlaceImage(photoReference: trip.photo_reference, maxHeight: 100) { (image) in
            DispatchQueue.main.async {
                cell.mainImage.image = image
            }
        }
        cell.tripNameLabel.text = trip.name
        cell.tripDatesLabel.text = "\(startDateString) - \(endDateString)"
        
        return(cell)
    }
    
    // perform segue to show itinerary for selected trip
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "showItinerary", sender: self)
    }
    
    // swiping a cell to delete the trip
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            tripsManager.delete(id: allTrips[indexPath.section][indexPath.row].id) { (successful) in
                print (successful)
            }
            allTrips[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // prepare segue with required variables
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // since multiple segues take place from this view controller, check which one it is
        if segue.identifier == "showItinerary" {
            if let itineraryViewController = segue.destination as? ItineraryViewController,
                let indexPath = selectedIndexPath {
                let selectedTrip = self.allTrips[indexPath.section][indexPath.row]
                setup(itineraryViewController: itineraryViewController, trip: selectedTrip)
            }
        }
        
        if segue.identifier == "showAutocompleteTrip" {
            let placePredictionViewController = segue.destination as? PlacePredictionViewController
            placePredictionViewController?.previousView = "trips"
        }
    }
    
    func setup(itineraryViewController: ItineraryViewController, trip: TripResponse) {
        itineraryViewController.trip = trip
    }
    
    // get all of the user's trips
    func fetchTrips () {
        tripAppApi.getTrips(emailAddress: credentialsStore.getCredentials()?.emailAddress ?? "", password: credentialsStore.getCredentials()?.password ?? "") { (array) in
            self.allTrips = array.map { [$0] }
            DispatchQueue.main.async {
                self.tripTableView.reloadData()
            }
        }
    }
    
    // perform segue to autocomplete screen when create button is clicked
    @IBAction func createTrip(_ sender: Any) {
        performSegue(withIdentifier: "showAutocompleteTrip", sender: self)
    }
}
