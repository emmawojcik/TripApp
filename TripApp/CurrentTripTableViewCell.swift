
import UIKit

class CurrentTripTableViewCell: UITableViewCell {
    
    private var placesApi: PlacesApi = PlacesApi()
    
    @IBOutlet weak var tripImageView: UIImageView!
    
    @IBOutlet weak var tripNameLabel: UILabel!
    
    @IBOutlet weak var tripDatesLabel: UILabel!
    
    @IBOutlet weak var tripTypeLabel: UILabel!
    
    @IBOutlet weak var viewTripBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func customise(trip: TripResponse, isCurrentTrip: Bool) {
        
        placesApi.getPlaceImage(photoReference: trip.photo_reference, maxHeight: Int(tripImageView.bounds.height)) { (image) in
            DispatchQueue.main.async {
                self.tripImageView.image = image
            }
        }
        if isCurrentTrip {
            tripTypeLabel.text = "Your current trip:"
        } else {
            tripTypeLabel.text = "Your upcoming trip:"
        }
        var startDateString = ""
        var endDateString = ""
        tripNameLabel.text = trip.name
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatterGet.timeZone = TimeZone(secondsFromGMT: 0)

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE d MMMM"
        
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
        tripDatesLabel.text = "\(startDateString) - \(endDateString)"
        
    }

}
