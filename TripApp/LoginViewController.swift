
import UIKit

class LoginViewController: UIViewController {
    
    private let credentialsManager: CredentialsManager = CredentialsManager()
    
    @IBOutlet private weak var emailAddressField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // if user is already logged in, show trips screen
        if credentialsManager.isLoggedIn() {
            performSegue(withIdentifier: "showTrips", sender: self)
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        // unwrap email address and check not empty
        guard let emailAddress = emailAddressField.text,
            !emailAddress.isEmpty else {
                displayEmailAddressErrorMessage()
                return
            }
        
        // unwrap password and check not empty
        guard let password = passwordField.text,
            !password.isEmpty else {
                displayPasswordErrorMessage()
                return
            }
        
        credentialsManager.login(emailAddress: emailAddress, password: password) { (successful) in
            // because all UI code must be performed on the main thread
            DispatchQueue.main.async {
                if successful == true {
                    self.performSegue(withIdentifier: "showTrips", sender: self)
                }
                else {
                    self.displayLoginFailedErrorMessage()
                }
            }
        }
    }
    
    // invalid entry error messages
    private func displayEmailAddressErrorMessage() {
        let alertController = UIAlertController(title: "Please enter a valid email address.",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayPasswordErrorMessage() {
        let alertController = UIAlertController(title: "Please enter a valid password.",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayLoginFailedErrorMessage() {
        let alertController = UIAlertController(title: "Incorrect email address or password.",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // perform segue to sign up page
    @IBAction func signUp(_ sender: UIButton) {
        performSegue(withIdentifier: "showSignUp", sender: self)
    }
}
