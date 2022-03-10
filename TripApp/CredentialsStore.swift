
import Foundation

struct Credentials: Codable {
    let emailAddress: String
    let password: String
}

class CredentialsStore {
    
    private let emailAddressKey: String = "credentialsEmail"
    private let passwordKey: String = "credentialsPassword"
    private let userDefaults: UserDefaults = .standard
    
    // remove credentials from user defaults
    func clear() {
        userDefaults.removeObject(forKey: emailAddressKey)
        userDefaults.removeObject(forKey: passwordKey)
    }
    
    // store credentials in user defaults
    func store(credentials: Credentials) {
        userDefaults.set(credentials.emailAddress, forKey: emailAddressKey)
        userDefaults.set(credentials.password, forKey: passwordKey)
    }
    
    // return credentials to be used when required
    func getCredentials() -> Credentials? {
        guard let emailAddress = userDefaults.string(forKey: emailAddressKey),
            let password = userDefaults.string(forKey: passwordKey) else {
            return nil
        }
        return Credentials(emailAddress: emailAddress, password: password)
    }
}
