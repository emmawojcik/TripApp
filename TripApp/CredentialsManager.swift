
import Foundation

class CredentialsManager {
    
    private let credentialsStore = CredentialsStore()
    private let tripAppApi = TripAppApi()
    
    func createAccount(emailAddress: String, password: String, completion: @escaping (Bool) -> Void) {

        // send request to server to create account
        tripAppApi.createAccount(emailAddress: emailAddress, password: password, completion: { successful in
            if successful {
                // if successful then save credential "token" on device and return "true" to completion
                self.credentialsStore.store(credentials: Credentials(emailAddress: emailAddress, password: password))
            } else {
                // otherwise don't save and return false
            }
            completion(successful)
        })
    }
    
    func login(emailAddress: String, password:String, completion: @escaping (Bool) -> Void) {
        // remove any previously stored credentials
        credentialsStore.clear()
        
        tripAppApi.login(emailAddress: emailAddress, password: password, completion: { successful in
            if successful {
                // if successful then save credential "token" on device and return "true" to completion
                self.credentialsStore.store(credentials: Credentials(emailAddress: emailAddress, password: password))
            } else {
                // otherwise don't save and return false
            }            
            completion(successful)
        })
    }
    
    // check if user is logged in
    func isLoggedIn() -> Bool {
        return credentialsStore.getCredentials() != nil 
    }
    
    func emailAddress() -> String? {
        return credentialsStore.getCredentials()?.emailAddress
    }
    
    func logOut() {
        credentialsStore.clear()
    }
}
