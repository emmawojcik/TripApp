
import UIKit

class SignUpViewController: UIViewController {
    
    private let credentialsManager: CredentialsManager = CredentialsManager()

    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var verifyPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createAccount(_ sender: Any) {
        
        // unwrap and validate email requirements
        guard let emailAddress = emailAddressField.text,
            !emailAddress.isEmpty,
            isValidEmail(emailAddress) else {
                displayEmailAddressErrorMessage()
                return
        }
        
        // unwrap and validate password requirements
        guard let password = passwordField.text,
            !password.isEmpty,
            let verifyPassword = verifyPasswordField.text,
            password == verifyPassword,
            password.count >= 8 else {
                displayPasswordErrorMessage()
                return
        }
        
        credentialsManager.createAccount(emailAddress: emailAddress, password: password) { (successful) in
            print(successful)
            DispatchQueue.main.async {
                if (successful) {
                    self.performSegue(withIdentifier: "showTripsAfterSignUp", sender: self)
                } else {
                    self.displayUserAlreadyExistsErrorMessage()
                }
            }
        }
    }
    
    // validate email solution from https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // valid entry error messages
    private func displayEmailAddressErrorMessage() {
        let alertController = UIAlertController(title: "Please enter a valid email address.",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayPasswordErrorMessage() {
        let alertController = UIAlertController(title: "Please enter a valid password which is at least 8 characters.",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayUserAlreadyExistsErrorMessage() {
        let alertController = UIAlertController(title: "Looks like you already have an account! Please log in.",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
