import Foundation

struct Target: Identifiable {
    let id = UUID()
    var appleUserID: String
    var name: String
    var age: String
    var gender: String
    var languages: String
    var interests: String // Nuova proprietà aggiunta!
    var profileImageData: Data?
    var airport: String
    var flightInfo: String
    var destination: String
    var departureTime: Date
}
