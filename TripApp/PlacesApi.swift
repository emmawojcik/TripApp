
import Foundation
import UIKit
import CoreLocation

struct PlaceToAutocomplete: Codable {
    let placeName: String
}

struct Prediction: Codable {
    let placeName: String
    let placeIdentifier: String
}

struct ReferenceForDetails: Codable {
    let placeIdentifier: String
    let maxHeight: Int
}

struct PlaceDetails: Codable {
    let name: String
    let latitude: Float
    let longitude: Float
    let photoReference: String?
    let website: String?
    let address: String
    let phoneNumber: String?
    let openingHours: [String]?
}

struct PhotoRequest: Codable {
    let photoReference: String
    let maxHeight: Int
}

struct SearchMapRequest: Codable {
    let location: String
    let radius: Int
    let type: String
}

struct SearchMapItem: Codable {
    let latitude: Float
    let longitude: Float
    let photoReference: String?
    let name: String
    let rating: Float
    let placeIdentifier: String
    let type: String
}
class PlacesApi {
    
    func autocompletePlaces (placeName: String, completion: @escaping ([Prediction]) -> Void) {
        
        // build a new request
        let url = URL(string: "http://localhost:3000/places/autocomplete")!
        var request = URLRequest(url: url)
        let placeBody = PlaceToAutocomplete(placeName: placeName)
        var placesArray: [Prediction] = []
                
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(placeBody) else {
            completion(placesArray)
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
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let predictions = try decoder.decode([Prediction].self, from: data)
                    placesArray = predictions
                }
                catch {
                    print(error)
                }
            }
            completion(placesArray)
        }.resume()
    }
    
    func getPlaceDetails (placeIdentifier: String, completion: @escaping (PlaceDetails?) -> Void) {
        
        // build a new request
        let url = URL(string: "http://localhost:3000/places/placeDetails")!
        var request = URLRequest(url: url)
        let maxHeight = 400
        let placeDetailBody = ReferenceForDetails(placeIdentifier: placeIdentifier, maxHeight: maxHeight)
                
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(placeDetailBody) else {
            completion(nil)
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
            var placeDetails: PlaceDetails?
            
            // parse data from JSON
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let placeDetailsResponse = try decoder.decode([String : PlaceDetails].self, from: data)
                    placeDetails = placeDetailsResponse["result"]
                }
                catch {
                    print(error)
                }
            }
            completion(placeDetails)
        }.resume()
    }
    
    func getPlaceImage(photoReference: String, maxHeight: Int, completion: @escaping (UIImage?) -> Void) {
        // get the device's screen scale to account for pixel density
        // (for example, 1x, 2x, 3x)
        let scale = UIScreen.main.scale
        let url = URL(string: "http://localhost:3000/places/placeImage")!
        var request = URLRequest(url: url)
        let imageRequestBody = PhotoRequest(photoReference: photoReference, maxHeight: maxHeight * Int(scale))
                
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(imageRequestBody) else {
            completion(nil)
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
            
            if let data = data {
                completion(UIImage(data: data))
            }
            else {
                completion(nil)
            }
        }.resume()
    }
    
    func searchMap(location: CLLocationCoordinate2D, radius: Int, type: String, completion: @escaping ([SearchMapItem]) -> Void){
        let url = URL(string: "http://localhost:3000/places/mapSearch")!
        var request = URLRequest(url: url)
        let locationString: String = String(format: "%f,%f", location.latitude, location.longitude)
        let mapRequestBody = SearchMapRequest(location: locationString, radius: radius, type: type)
                
        // fail early if can't create JSON body
        guard let requestBody = try? JSONEncoder().encode(mapRequestBody) else {
            completion([])
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
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let body = try decoder.decode([String:[SearchMapItem]].self, from: data)
                    completion(body["items"] ?? [])
                }
                catch {
                    print(error)
                }
            }
            else {
                completion([])
            }
            
        }.resume()
    }
    
}
