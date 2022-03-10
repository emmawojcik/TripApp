
import Foundation

struct Trip: Codable {
    let tripName: String
    let destination: String
    let startDate: String
    let endDate: String
    let placeIdentifier: String
    let emailAddress: String
    let password: String
}

struct Event: Codable {
    let eventName: String
    let placeName: String
    let startDate: String
    let duration: Int
    let tripId: Int
    let placeIdentifier: String
    let emailAddress: String
    let password: String
}

struct RetrieveEvent: Codable {
    let tripId: Int
    let emailAddress: String
    let password: String        
}

struct DeleteEvent: Codable {
    let eventId: Int
    let emailAddress: String
    let password: String
}

struct DeleteTrip: Codable {
    let tripId: Int
    let emailAddress: String
    let password: String
}

class TripAppApi {
        
    func createAccount(emailAddress: String, password: String, completion: @escaping (Bool) -> Void) {
        
        // build a new request
        let url = URL(string: "http://localhost:3000/users/signup")!
        var request = URLRequest(url: url)
        let signUpBody = Credentials(emailAddress: emailAddress,
                                    password: password)
        
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(signUpBody) else {
            completion(false)
            return
        }
        
        // send data as POST data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        
        // post it to the server
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                return completion(false)
            }
            
            guard let response = response as? HTTPURLResponse else {
                return completion(false)
            }
            
            // 200 to 299 is successful http code range
            guard (200..<299).contains(response.statusCode) else {
                return completion(false)
            }
            
            completion(true)
        }.resume()
        
    }
    
    func login(emailAddress: String,
               password: String,
               completion: @escaping (Bool) -> Void) {
        
        // build a new request
        let url = URL(string: "http://localhost:3000/users/login")!
        var request = URLRequest(url: url)
        
        let loginBody = Credentials(emailAddress: emailAddress,
                                    password: password)
        
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(loginBody) else {
            completion(false)
            return
        }
        
        // send data as POST data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestBody
                
        // post it to the server
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                return completion(false)
            }
            
            guard let response = response as? HTTPURLResponse else {
                return completion(false)
            }
            
            guard (200..<299).contains(response.statusCode) else {
                return completion(false)
            }
            completion(true)
        }.resume()
    }
    
    func createTrip(tripName: String,
                    destination: String,
                    startDate: String,
                    endDate: String,
                    placeIdentifier: String,
                    credentials: Credentials,
                    completion: @escaping (Bool) -> Void) {
        
        // build a new request
        let url = URL(string: "http://localhost:3000/trips/new")!
        var request = URLRequest(url: url)
        let tripBody = Trip(tripName: tripName, destination: destination, startDate: startDate,
                            endDate: endDate, placeIdentifier: placeIdentifier, emailAddress: credentials.emailAddress, password: credentials.password)
        
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(tripBody) else {
            completion(false)
            return
        }
                
        // send data as POST data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        // post it to the server
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                return completion(false)
            }
            
            guard let response = response as? HTTPURLResponse else {
                return completion(false)
            }
            
            guard (200..<299).contains(response.statusCode) else {
                return completion(false)
            }
            
            completion(true)
        }.resume()
    }
    
    func getTrips (emailAddress: String,
                   password: String,
                   completion: @escaping ([TripResponse]) -> Void) {

        // build a new request
        let url = URL(string: "http://localhost:3000/trips/allTrips")!
        var request = URLRequest(url: url)
        let userBody = Credentials(emailAddress: emailAddress,
                                    password: password)
        var tripsArray: [TripResponse] = []
                
        guard let requestBody = try? JSONEncoder().encode(userBody) else {
            completion(tripsArray)
            return
        }
        
        // send data as POST data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        // post it to the server
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            
            if error != nil {
                print(error ?? "")
            }
            
            // parse data from JSON
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let tripResponse = try decoder.decode([TripResponse].self, from: data)
                    tripsArray = tripResponse
                    print(tripsArray)
                }
                catch {
                    print(error)
                }
            }
            completion(tripsArray)

        }.resume()
    }
    
    func deleteTrip (tripId: Int, credentials: Credentials, completion: @escaping (Bool) -> Void) {
        
        let url = URL(string: "http://localhost:3000/trips/deleteTrip")!
        var request = URLRequest(url: url)
        let deleteTripBody = DeleteTrip (tripId: tripId, emailAddress: credentials.emailAddress, password: credentials.password)
                
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(deleteTripBody) else {
            completion(false)
            return
        }
        
        // send data as POST data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        // post it to the server
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                return completion(false)
            }
            
            guard let response = response as? HTTPURLResponse else {
                return completion(false)
            }
            
            guard (200..<299).contains(response.statusCode) else {
                return completion(false)
            }
            completion(true)
        }.resume()
    }
    
    func createEvent (eventName: String,
                      placeName: String,
                      startDate: String,
                      duration: Int,
                      tripId: Int,
                      placeIdentifier: String,
                      credentials: Credentials,
                      completion: @escaping (Bool) -> (Void)) {
        
        let url = URL(string: "http://localhost:3000/events/new")!
        var request = URLRequest(url: url)
        let eventBody = Event (eventName: eventName, placeName: placeName, startDate: startDate, duration: Int(duration), tripId: tripId, placeIdentifier: placeIdentifier, emailAddress: credentials.emailAddress, password: credentials.password)
        
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(eventBody) else {
            completion(false)
            return
        }
                
        // send data as POST data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        // post it to the server
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                return completion(false)
            }
            
            guard let response = response as? HTTPURLResponse else {
                return completion(false)
            }
            
            guard (200..<299).contains(response.statusCode) else {
                return completion(false)
            }            
            completion(true)
        }.resume()
        
    }
    
    
    func getEvents (tripId: Int,
                    emailAddress: String,
                    password: String,
                    completion: @escaping ([EventResponse]) -> Void) {
        
        let url = URL(string: "http://localhost:3000/events/allEvents")!
        var request = URLRequest(url: url)
        let retrieveEventBody = RetrieveEvent (tripId: tripId, emailAddress: emailAddress, password: password)
        
        var eventsArray: [EventResponse] = []
        
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(retrieveEventBody) else {
            completion(eventsArray)
            return
        }
                
        // send data as POST data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        // post it to the server
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            
                if error != nil {
                    print(error ?? "")
                }
                // parse data from JSON
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let eventsResponse = try decoder.decode([EventResponse].self, from: data)
                        eventsArray = eventsResponse
                    }
                    catch {
                        print(error)
                    }
                }
                completion(eventsArray)
            }.resume()
    }
    
    func deleteEvent (eventId: Int,
                      credentials: Credentials,
                      completion: @escaping (Bool) -> Void) {
        
        let url = URL(string: "http://localhost:3000/events/deleteEvent")!
        var request = URLRequest(url: url)
        let deleteEventBody = DeleteEvent (eventId: eventId, emailAddress: credentials.emailAddress, password: credentials.password)
                
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(deleteEventBody) else {
            completion(false)
            return
        }
        
        // send data as POST data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        // post it to the server
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                return completion(false)
            }
            
            guard let response = response as? HTTPURLResponse else {
                return completion(false)
            }
            
            guard (200..<299).contains(response.statusCode) else {
                return completion(false)
            }
            completion(true)
        }.resume()
        
    }
    
}
