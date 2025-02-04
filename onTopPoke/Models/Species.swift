import Foundation

/// Response from the `getSpeciesList` endpoint
struct SpeciesResponse: Decodable {
    let count: Int
    let results: [Species]
}

/// Species object returned as part of the `SpeciesResponse` object from the `getSpeciesList` endpoint
struct Species: Decodable, Equatable {
    let name: String
    let url: URL
    var id: Int? {
        guard let idString = url.pathComponents.last, let id = Int(idString) else { return nil }
        return id
    }
    
    var imageUrl: URL? {
        guard let id = id else { return nil }
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }
}
