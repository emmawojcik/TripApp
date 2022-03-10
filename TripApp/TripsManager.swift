
import Foundation

class TripsManager {
    
    private let tripAppApi: TripAppApi = TripAppApi ()
    private let credentialsStore: CredentialsStore = CredentialsStore ()
    
    // send request to server to create a trip using user credentials
    func create(tripName: String, destination: String, startDate: String, endDate: String, placeIdentifier: String, completion: (Bool) -> Void) {
        guard let credentials = credentialsStore.getCredentials() else {
            return
        }
        tripAppApi.createTrip(tripName: tripName, destination: destination, startDate: startDate, endDate: endDate,
                              placeIdentifier: placeIdentifier, credentials: credentials, completion: { (successful) in
                                
                                print(successful)
        })        
    }
    
    // send request to server to delete trip using user credentials
    func delete (id: Int, completion: (Bool) -> Void) {
        
        guard let credentials = credentialsStore.getCredentials() else {
            return
        }
        
        tripAppApi.deleteTrip(tripId: id, credentials: credentials, completion: { (successful) in
            print(successful)
        })
    }
}
