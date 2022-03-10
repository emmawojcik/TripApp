
import UIKit

class PlaceOfInterestDetailView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    private let placesApi: PlacesApi = PlacesApi ()
    
    // make the annotation detail view
    static func make() -> PlaceOfInterestDetailView {
        // instantiate the xib file
        let nib = UINib(nibName: "PlaceOfInterestDetailView", bundle: nil)
        let detailView = nib.instantiate(withOwner: nil, options: nil).first as! PlaceOfInterestDetailView
        detailView.translatesAutoresizingMaskIntoConstraints = false
        return detailView
    }
    
    // customise the annotation view with data from google places api
    func customise(searchMapItem: SearchMapItem) {
        if let photoReference = searchMapItem.photoReference {
            placesApi.getPlaceImage(photoReference: photoReference, maxHeight: Int(imageView.bounds.height)) { (image) in
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
        titleLabel.text = searchMapItem.name
        typeLabel.text = searchMapItem.type
        var ratingsString = ""
        for _ in 0..<Int(searchMapItem.rating) {
            ratingsString.append("⭐️")
        }
        ratingLabel.text = "\(ratingsString)(\(searchMapItem.rating))"
    }
}
