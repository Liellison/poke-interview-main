import Foundation

/// Species object returned as part of the `getSpeciesDetails` endpoint
struct SpeciesDetails {
    let name: String
    let evolutionChain: EvolutionChain
}

/// EvolutionChain model returned as part of the SpeciesDetails from the `getSpecies` endpoint
struct EvolutionChain {
    let url: URL
}
