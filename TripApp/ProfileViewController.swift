
import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum Cell {
        case logOut
        case emailAddress
    }
    
    private let credentialsManager: CredentialsManager = CredentialsManager()
    private var sections: [[Cell]] = [[.emailAddress], [.logOut]]

    @IBOutlet weak var profileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section][indexPath.row] {
        case .emailAddress:
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailAddressCell", for: indexPath)
            cell.textLabel?.text = credentialsManager.emailAddress()
            return cell
            
        case .logOut:
            return tableView.dequeueReusableCell(withIdentifier: "logOutCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section][indexPath.row] {
        case .emailAddress:
            break
            
        case .logOut:
            let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (_) in
                self.credentialsManager.logOut()
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
