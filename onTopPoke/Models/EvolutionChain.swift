import Foundation

/// EvolutionChain model returned from the `getEvolutionChain` endpoint
struct EvolutionChainDetails: Decodable {
    let chain: ChainLink
}

/// ChainLink model returned as part of the EvolutionChainDetails from the `getEvolutionChain` endpoint
struct ChainLink: Decodable {
    let species: Species
    let evolvesTo: [ChainLink]
    
    enum CodingKeys: String, CodingKey {
            case species
            case evolvesTo = "evolves_to"
        }
}

extension ChainLink {
    func getAllEvolutions() -> [Species] {
        var evolutions: [Species] = [species]
        for evolution in evolvesTo {
            evolutions.append(contentsOf: evolution.getAllEvolutions())
        }
        return evolutions
    }
}
