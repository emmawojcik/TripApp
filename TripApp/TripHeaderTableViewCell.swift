
import UIKit

class TripHeaderTableViewCell: UITableViewCell {

   private var placesApi: PlacesApi = PlacesApi()
   
   @IBOutlet weak var tripImageView: UIImageView!
   
   @IBOutlet weak var tripNameLabel: UILabel!
   
   @IBOutlet weak var tripDatesLabel: UILabel!
   
   override func awakeFromNib() {
       super.awakeFromNib()
       // Initialization code
   }

   override func setSelected(_ selected: Bool, animated: Bool) {
       super.setSelected(selected, animated: animated)
       // Configure the view for the selected state
   }
   
    // customise the header with the trip info
   func customise(trip: TripResponse) {
       placesApi.getPlaceImage(photoReference: trip.photo_reference, maxHeight: Int(tripImageView.bounds.height)) { (image) in
           DispatchQueue.main.async {
               self.tripImageView.image = image
           }
       }
       
       var startDateString = ""
       var endDateString = ""
       tripNameLabel.text = trip.name
       let dateFormatterGet = DateFormatter()
       dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
       dateFormatterGet.timeZone = TimeZone(secondsFromGMT: 0)

       let startDateFormatterPrint = DateFormatter()
       startDateFormatterPrint.dateFormat = "EEEE d MMMM"
       
       let endDateFormatterPrint = DateFormatter()
       endDateFormatterPrint.dateFormat = "EEEE d MMMM YYYY"
       
       if let startDateToFormat = dateFormatterGet.date(from: trip.start_date) {
           startDateString = startDateFormatterPrint.string(from: startDateToFormat)
       } else {
          print("Unable to decode the string")
       }
       if let endDateToFormat = dateFormatterGet.date(from: trip.end_date) {
           endDateString = endDateFormatterPrint.string(from: endDateToFormat)
       } else {
           print("Unable to decode the string")
       }
       tripDatesLabel.text = "\(startDateString) - \(endDateString)"
   }


}
