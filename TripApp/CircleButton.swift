
import UIKit

class CircleButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .systemBlue
        tintColor = .white
        layer.cornerRadius = frame.height / 2
    }
}
