
import UIKit

class TripCreatorViewController: UIViewController {
    
    private let tripsManager: TripsManager = TripsManager()
    private var startDate: Date?
    private var endDate: Date?
    var place: Prediction!
    
    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        destinationField.text = place.placeName
        
        // use scrolling date picker instead of manual date entry
        let startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = UIDatePicker.Mode.date
        startDatePicker.addTarget(self, action: #selector(TripCreatorViewController.startDatePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        startDateField.inputView = startDatePicker

        let endDatePicker = UIDatePicker()
        endDatePicker.datePickerMode = UIDatePicker.Mode.date
        endDatePicker.addTarget(self, action: #selector(TripCreatorViewController.endDatePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        endDateField.inputView = endDatePicker
    }
    
    @objc func startDatePickerValueChanged(sender: UIDatePicker) {
        startDate = sender.date
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        startDateField.text = formatter.string(from: sender.date)
        startDate = sender.date
        
    }

    @objc func endDatePickerValueChanged(sender: UIDatePicker) {
        endDate = sender.date
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        endDateField.text = formatter.string(from: sender.date)
        
        // check end date is after start date, otherwise display error
        guard let startDate = self.startDate, sender.date >= startDate else {
            displayInvalidEndDateErrorMessage()
            return
        }
    }
    
    @IBAction func createTrip(_ sender: Any) {
        
        guard let tripName = tripNameField.text,
            !tripName.isEmpty else {
                displayTripNameErrorMessage()
                return
        }
        
        guard let destination = destinationField.text,
            !destination.isEmpty else {
                displayDestinationErrorMessage()
                return
        }
        
        // format date from date picker
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        
        guard let startDate = self.startDate else {
                displayStartDateErrorMessage()
                return
        }
        
        let startDateString = formatter.string(from: startDate)
        
        guard let endDate = self.endDate,
                startDate <= endDate else {
                displayEndDateErrorMessage()
                return
        }
        
        let endDateString = formatter.string(from: endDate)
        
        // create trip
        tripsManager.create(tripName: tripName, destination: destination, startDate: startDateString, endDate: endDateString, placeIdentifier: place.placeIdentifier) { (successful) in
            print(successful)
        }
        // return to "trips" screen after trip creation
        performSegue(withIdentifier: "returnToTrips", sender: self)
    }
    
    
    // Validate user entry error messages
    
    private func displayTripNameErrorMessage() {
        let alertController = UIAlertController(title: "Please enter a trip name",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayDestinationErrorMessage() {
        let alertController = UIAlertController(title: "Please enter a destination",
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
    
    private func displayEndDateErrorMessage() {
        let alertController = UIAlertController(title: "Please enter an end date",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayInvalidEndDateErrorMessage() {
        let alertController = UIAlertController(title: "End date must be after start date",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    
}
