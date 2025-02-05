//
//  DetailsViewViewModel.swift
//  onTopPoke
//
//  Created by Liellison Menezes on 05/02/25.
//

import Foundation
import Combine

class DetailsViewModel: ObservableObject {
    @Published var species: Species
    @Published var evolutionChain: [Species] = []
    @Published var isAnimating = false

    private let service: PokemonServiceProtocol

    init(species: Species, service: PokemonServiceProtocol = PokemonService()) {
        self.species = species
        self.service = service
    }
    
    /// Search for current species details
    func fetchSpeciesDetails() {
        service.fetchSpeciesDetails(for: species.name) { [weak self] result in
            switch result {
            case .success(let speciesDetails):
                self?.fetchEvolutionChain(from: speciesDetails.evolutionChain.url)
            case .failure(let error):
                print("Error fetching species details:", error)
            }
        }
    }
    
    /// Search the evolutionary chain from the received URL
    private func fetchEvolutionChain(from url: URL) {
        service.fetchEvolutionChain(from: url) { [weak self] result in
            switch result {
            case .success(let evolutionChainDetails):
                let evolutions = evolutionChainDetails.chain.getAllEvolutions()
                DispatchQueue.main.async {
                    self?.evolutionChain = evolutions
                }
            case .failure(let error):
                print("Error searching for evolutionary chain:", error)
            }
        }
    }
    
    /// Updates the current species and restarts the evolutionary chain
    func updateSpecies(_ newSpecies: Species) {
        DispatchQueue.main.async {
            self.species = newSpecies
            self.evolutionChain = []
        }
    }
}
