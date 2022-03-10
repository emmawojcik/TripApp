
import UIKit

class EventCreatorViewController: UIViewController {
    
    private let eventsManager: EventsManager = EventsManager()
    private let placesApi: PlacesApi = PlacesApi()
    private var startDate: Date?
    
    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var placeNameField: UITextField!
    var trip: TripResponse!
    var place: Prediction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let startDatePicker = UIDatePicker()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        startDatePicker.minimumDate = formatter.date(from: trip.start_date)
        startDatePicker.maximumDate = formatter.date(from: trip.end_date)
        startDatePicker.datePickerMode = UIDatePicker.Mode.date
        startDatePicker.addTarget(self, action: #selector(TripCreatorViewController.startDatePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        startDateField.inputView = startDatePicker
        placeNameField.text = place.placeName
    }
    
    @objc func startDatePickerValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        startDateField.text = formatter.string(from: sender.date)
        startDate = sender.date
    }
    
    @IBAction func createEvent(_ sender: Any) {
        
        guard let eventName = eventNameField.text,
            !eventName.isEmpty else {
                displayEventNameErrorMessage()
                return
        }
        
        guard let placeName = placeNameField.text,
            !placeName.isEmpty else {
                displayEndDateErrorMessage()
                return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        
        guard let startDate = self.startDate else {
                displayStartDateErrorMessage()
                return
        }
        
        let startDateString = formatter.string(from: startDate)
        
        // create event
        eventsManager.create(eventName: eventName, placeName: placeName, startDate: startDateString, duration: 0, tripId: trip.id, placeIdentifier: place.placeIdentifier) { (successful) in
            print(successful)
        }
        // return to itinerary after creating event
        performSegue(withIdentifier: "returnToItinerary", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let itineraryViewController = segue.destination as! ItineraryViewController
        itineraryViewController.trip = self.trip
    }
    
    
    // Validate user input error messages
    
    private func displayEventNameErrorMessage() {
        let alertController = UIAlertController(title: "Please enter an event name",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayEventTypeErrorMessage() {
        let alertController = UIAlertController(title: "Please enter an event type",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    private func displayStartDateErrorMessage() {
        let alertController = UIAlertController(title: "Please enter a start date",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayStartTimeErrorMessage() {
        let alertController = UIAlertController(title: "Please enter a start time",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayEndDateErrorMessage() {
        let alertController = UIAlertController(title: "Please enter an end date",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayEndTimeErrorMessage() {
        let alertController = UIAlertController(title: "Please enter an end time",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}
