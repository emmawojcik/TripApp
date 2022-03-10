
import UIKit

class YourTripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum Cell {
        case noTrips
        case upcomingTrip
        case currentTrip
    }
    
    private var cell: Cell = .noTrips
    private let tripAppApi = TripAppApi()
    private let credentialsStore = CredentialsStore()
    private var tripResponse: TripResponse?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cell {
        case .noTrips:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoTripsCell", for: indexPath) as! NoTripsTableViewCell
            cell.createTripBtn.addTarget(self, action: #selector(createTripButtonWasPressed), for: .touchUpInside)
            return cell
        case .upcomingTrip:
            // use current trip cell since upcoming trip and current trip cells are very similar layouts
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentTripCell", for: indexPath) as! CurrentTripTableViewCell
            if let tripResponse = tripResponse {
                cell.customise(trip: tripResponse, isCurrentTrip: false)
            }
            cell.viewTripBtn.addTarget(self, action: #selector(viewTripButtonWasPressed), for: .touchUpInside)
            return cell
        case .currentTrip:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentTripCell", for: indexPath) as! CurrentTripTableViewCell
            if let tripResponse = tripResponse {
                cell.customise(trip: tripResponse, isCurrentTrip: true)
            }
            cell.viewTripBtn.addTarget(self, action: #selector(viewTripButtonWasPressed), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height * 0.8
    }
    
    func fetchData () {
        // return early if credntials don't exist
        guard let credentials = credentialsStore.getCredentials() else {
            return
        }
        // retrieve user's trips
        tripAppApi.getTrips(emailAddress: credentials.emailAddress, password: credentials.password) { (trips) in
            self.present(trips: trips)
        }
    }
    
    func present(trips: [TripResponse]) {
        let now = Date()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatterGet.timeZone = TimeZone(secondsFromGMT: 0)
        
        // present empty state when user has no trips
        if trips.isEmpty {
            self.cell = .noTrips
        
        // present current trip if current date is within start date and end date of trip
        } else if let currentTrip = trips.first(where: { (trip) in
            if let startDate = dateFormatterGet.date (from: trip.start_date),
                let endDate = dateFormatterGet.date (from: trip.end_date) {
                    return now >= startDate && now < endDate
            }
            return false
        }) {
            self.cell = .currentTrip
            self.tripResponse = currentTrip
            
        // present an upcoming trip (the earliest trip in the future)
        } else if let upcomingTrip = trips.first(where: { (trip) in
            if let startDate = dateFormatterGet.date (from: trip.start_date) {
                return startDate > now
            }
            return false
        }) {
            self.cell = .upcomingTrip
            self.tripResponse = upcomingTrip
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PlacePredictionViewController {
            viewController.previousView = "trips"
        } else if let viewController = segue.destination as? ItineraryViewController, let trip = tripResponse {
            viewController.trip = trip
        }
        
    }
    
    @objc func createTripButtonWasPressed () {
        performSegue(withIdentifier: "CreateTrip", sender: self)
    }
    
    @objc func viewTripButtonWasPressed () {
        performSegue(withIdentifier: "ViewTrip", sender: self)
    }
}
