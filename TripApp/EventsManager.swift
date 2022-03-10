
import Foundation

class EventsManager {
    
    private let tripAppApi: TripAppApi = TripAppApi ()
    private let credentialsStore: CredentialsStore = CredentialsStore ()
    
    // send request to create an event
    func create(eventName: String,
                placeName: String,
                startDate: String,
                duration: Int,
                tripId: Int,
                placeIdentifier: String,
                completion: (Bool) -> Void) {
        
        guard let credentials = credentialsStore.getCredentials() else {
            return
        }
        
        tripAppApi.createEvent(eventName: eventName, placeName: placeName, startDate: startDate, duration: duration, tripId: tripId, placeIdentifier: placeIdentifier, credentials: credentials, completion: { (successful) in
            
            print(successful)
        })
        
    }
    
    // send request to delete event
    func delete (id: Int, completion: (Bool) -> Void) {
        
        guard let credentials = credentialsStore.getCredentials() else {
            return
        }
        tripAppApi.deleteEvent(eventId: id, credentials: credentials, completion: { (successful) in
            print(successful)
        })
    }
    
}
