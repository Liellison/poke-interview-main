import Foundation

/// Species object returned as part of the `getSpeciesDetails` endpoint
struct SpeciesDetails: Decodable {
    let name: String
    let evolutionChain: EvolutionChain
    
    enum CodingKeys: String, CodingKey {
            case name
            case evolutionChain = "evolution_chain"
        }
}

/// EvolutionChain model returned as part of the SpeciesDetails from the `getSpecies` endpoint
struct EvolutionChain: Decodable {
    let url: URL
}
