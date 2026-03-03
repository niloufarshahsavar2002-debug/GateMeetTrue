import Foundation
import Combine

class CloudKitService: ObservableObject {
    @Published var downloadedTargets: [Target] = []
    @Published var isSearching: Bool = false
    
    init() { loadMockData() }
    
    func loadMockData() {
        self.downloadedTargets = [
            Target(appleUserID: "1", name: "Giulia", age: "24", gender: "Female", languages: "Italian, English", interests: "Travel, Music, Art", profileImageData: nil, airport: "Naples (NAP)", flightInfo: "AZ123", destination: "London", departureTime: Date()),
            Target(appleUserID: "2", name: "Marco", age: "29", gender: "Male", languages: "Spanish", interests: "Sports, Tech, Food", profileImageData: nil, airport: "Naples (NAP)", flightInfo: "FR456", destination: "Paris", departureTime: Date()),
            Target(appleUserID: "3", name: "Sofia", age: "22", gender: "Female", languages: "French, German", interests: "Photography, Books", profileImageData: nil, airport: "Naples (NAP)", flightInfo: "LH789", destination: "Berlin", departureTime: Date())
        ]
    }
    
    func startScanning(myAirport: String, myTime: Date, myUserID: String) {
        self.isSearching = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.isSearching = false }
    }
    
    func saveMyProfile(appleUserID: String, name: String, age: String, gender: String, languages: String, interests: String, imageData: Data?, airport: String, flight: String, destination: String, departureTime: Date, completion: @escaping (Bool, String?) -> Void) {
        completion(true, nil) // Finge che il salvataggio sia sempre un successo immediato
    }
}
