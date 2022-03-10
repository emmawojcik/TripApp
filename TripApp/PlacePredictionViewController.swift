
import UIKit


class PlacePredictionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private let placesApi: PlacesApi = PlacesApi ()
    private var placesArray: [Prediction] = []
    private var selectedIndexPath: Int?
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var placeField: UITextField!
    var trip: TripResponse!
    var previousView: String!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placeField.delegate = self
    }
    
    // update place search every time text is changed
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        placesArray.removeAll()
        placesTableView.reloadData()
        
        let placeName = placeField.text ?? ""
            
        // send placeName and return an array of predictions
        placesApi.autocompletePlaces(placeName: placeName, completion: { (array) in
            for data in array {
                self.placesArray.append(data)
            }
                        
            DispatchQueue.main.async{
                self.placesTableView.reloadData()
            }
        })
        return true
    }
    
    // title for section header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if placesArray.isEmpty {
            return nil
        } else {
            return "Results:"
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesArray.count
    }
    
    // cells for table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        cell.textLabel?.text = placesArray[indexPath.row].placeName
        
        return (cell)
    }
    
    // a result cell is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath.row
        
        // show trip creator if previous view was trips screen
        if previousView == "trips" {
            performSegue(withIdentifier: "showTripCreator", sender: self)
        }
        
        // show event creator if previous view was itinerary screen
        if previousView == "itinerary" {
            performSegue(withIdentifier: "showEventCreator", sender: self)
        }
    }
    
    // setting the variables to be used in views displayed after segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showTripCreator" {
            if let tripCreatorViewController = segue.destination as? TripCreatorViewController,
                let indexPath = selectedIndexPath {
                let selectedPlace = placesArray[indexPath]
                tripCreatorViewController.place = selectedPlace
            }
        }
        
        if segue.identifier == "showEventCreator" {
            if let eventCreatorViewController = segue.destination as? EventCreatorViewController,
                let indexPath = selectedIndexPath {
                let selectedPlace = placesArray[indexPath]
                eventCreatorViewController.place = selectedPlace
                eventCreatorViewController.trip = trip
            }
        }
    }
    
    // empty location field error
    private func displayPlaceErrorMessage() {
        let alertController = UIAlertController(title: "Please enter a location",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}
