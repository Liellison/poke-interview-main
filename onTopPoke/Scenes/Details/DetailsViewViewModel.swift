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
    
    /// Busca os detalhes da espécie atual
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
    
    /// Busca a cadeia evolutiva a partir da URL recebida
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
    
    /// Atualiza a espécie atual e reinicia a cadeia evolutiva
    func updateSpecies(_ newSpecies: Species) {
        DispatchQueue.main.async {
            self.species = newSpecies
            self.evolutionChain = []
        }
    }
}
