//
//  DetailsViewViewModel.swift
//  onTopPoke
//
//  Created by Liellison Menezes on 05/02/25.
//

import Foundation
import SwiftUI
import Combine

class DetailsViewModel: ObservableObject {
    @Published var species: Species
    @Published var evolutionChain: [Species] = []
    @Published var isAnimating = false
    
    init(species: Species) {
        self.species = species
    }
    
    func fetchSpeciesDetails() {
        let request = APIRoute.getSpecies(URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(species.name)")!).asRequest()
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(SpeciesDetails.self, from: data)
                self.fetchEvolutionChain(from: decodedResponse.evolutionChain.url)
            } catch {
                print("Error fetching species details:", error)
            }
        }.resume()
    }
    
    func fetchEvolutionChain(from url: URL) {
        let request = APIRoute.getEvolutionChain(url).asRequest()
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(EvolutionChainDetails.self, from: data)
                let evolutions = decodedResponse.chain.getAllEvolutions()
                
                DispatchQueue.main.async {
                    self.evolutionChain = evolutions
                }
            } catch {
                print("Error searching for evolutionary chain:", error)
            }
        }.resume()
    }
}
