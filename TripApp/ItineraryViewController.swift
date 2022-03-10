
import UIKit

struct EventResponse: Codable {
    let name: String
    let place_name: String
    let start_date: String
    let duration: Int
    let id: Int
    let place_identifier: String
    let latitude: Float
    let longitude: Float
}

class ItineraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    enum Cell {
        case header
        case event (EventResponse)
    }
    
    @IBOutlet weak var eventTableView: UITableView!
    
    @IBAction func didPressMapBtn(_ sender: Any) {
        // only show map if there is at least 1 trip
        if allEvents.count > 0 {
            self.performSegue(withIdentifier: "showMap", sender: self)
        }
    }

    private let tripAppApi = TripAppApi()
    private let credentialsStore: CredentialsStore = CredentialsStore()
    private var allEvents: [EventResponse] = []
    private var selectedIndexPath: IndexPath?
    private let eventsManager: EventsManager = EventsManager ()
    private let tripsManager: TripsManager = TripsManager ()
    var cells: [[Cell]] = []
    var trip: TripResponse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEvents()
        eventTableView.reloadData()
        eventTableView.delegate = self
        eventTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        allEvents.removeAll()
        fetchEvents()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.cells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // format the dates into a presentable format
        var startDateString: String = ""
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatterGet.timeZone = TimeZone(secondsFromGMT: 0)

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE d MMMM"
        
        // layout cell differently depending on whether its a header or a event cell
        switch cells[indexPath.section][indexPath.row] {
        case .header:
            // header will display trip info
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripHeaderCell", for: indexPath) as! TripHeaderTableViewCell
            cell.customise(trip: trip)
            return cell
        case .event(let event):
            if let startDateToFormat = dateFormatterGet.date(from: event.start_date) {
                startDateString = dateFormatterPrint.string(from: startDateToFormat)
            } else {
               print("Unable to decode the string")
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
            cell.textLabel?.text = event.name
            cell.detailTextLabel?.text = startDateString
            
            return (cell)
        }
    }
    
    func fetchEvents () {
        guard let credentials = credentialsStore.getCredentials() else {
            return
        }
        tripAppApi.getEvents(tripId: trip.id, emailAddress: credentials.emailAddress, password: credentials.password) { (array) in
            self.allEvents = array
            // first section will be header, second section will be list of events
            self.cells = [
                [.header],
                array.map { Cell.event($0) }
            ]
            DispatchQueue.main.async {
                self.eventTableView.reloadData()
            }
        }
    }
    
    // a particular cell in table view is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cells[indexPath.section][indexPath.row] {
        case .header:
            return
        case .event:
            selectedIndexPath = indexPath
            performSegue(withIdentifier: "showEvent", sender: self)
        }
    }
    
    // title for section header (only show header for events section)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Your Events:"
        }
        return nil
    }
    
    // edit menu with options: add event, view map, delete trip
    func showItineraryActionSheet(controller: UIViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add Event", style: .default, handler: { (_) in
            print("User click Add button")
            self.performSegue(withIdentifier: "showPlaceAutocomplete", sender: self)
        }))


        alert.addAction(UIAlertAction(title: "Delete Trip", style: .destructive, handler: { (_) in
            let deleteAlert = UIAlertController(title: "Are you sure you want to delete the trip?", message: nil, preferredStyle: .actionSheet)
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                self.tripsManager.delete(id: self.trip.id) { (successful) in
                    print(successful)
                }
                self.performSegue(withIdentifier: "itineraryToTrips", sender: self)
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
        
        // setting the variables to be used in EventViewController
        if segue.identifier == "showEvent" {
            if let eventViewController = segue.destination as? EventViewController,
                let indexPath = selectedIndexPath {
                switch cells[indexPath.section][indexPath.row] {
                case .event(let event):
                    eventViewController.event = event
                    eventViewController.trip = trip
                case .header:
                    break
                }
            }
        }
        
        // setting the variables to be used in PlacePredictionViewController
        if segue.identifier == "showPlaceAutocomplete" {
            let placePredictionViewController = segue.destination as! PlacePredictionViewController
            placePredictionViewController.trip = self.trip
            placePredictionViewController.previousView = "itinerary"
        }
        
        if segue.identifier == "showMap" {            
            let mapViewController = segue.destination as! MapViewController
            mapViewController.events = allEvents
            mapViewController.trip = self.trip
        }
    }
    
    // swiping a cell to delete the event
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch cells[indexPath.section][indexPath.row] {
        case .event(let event):
            if editingStyle == .delete {
                eventsManager.delete(id: event.id) { (successful) in
                    print (successful)
                }
                cells[indexPath.section].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .header:
            return
        }
    }
    
    // clicking button displays edit menu
    @IBAction func editTrip(_ sender: Any) {
        showItineraryActionSheet(controller: self)
    }

}
