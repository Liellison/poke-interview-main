//
//  PokemonService.swift
//  onTopPoke
//
//  Created by Liellison Menezes on 05/02/25.
//

import Foundation

class PokemonService: PokemonServiceProtocol {
    private let requestHandler: RequestHandling
    
    init(requestHandler: RequestHandling = PokemonRequestHandler()) {
        self.requestHandler = requestHandler
    }
    
    /// Fetches a paginated list of Pokémon species from the API.
    func fetchPokemonList(limit: Int, offset: Int, completion: @escaping (Result<SpeciesResponse, Error>) -> Void) {
        let route = APIRoute.getSpeciesList(limit: limit, offset: offset)
        
        do {
            try requestHandler.request(route: route, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Fetches the details of a specific Pokémon species.
    func fetchSpeciesDetails(for speciesName: String, completion: @escaping (Result<SpeciesDetails, Error>) -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(speciesName)") else {
            completion(.failure(PokemonRequestError()))
            return
        }
        
        let route = APIRoute.getSpecies(url)
        
        do {
            try requestHandler.request(route: route, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Fetches the evolution chain for a given Pokémon species.
    func fetchEvolutionChain(from url: URL, completion: @escaping (Result<EvolutionChainDetails, Error>) -> Void) {
        let route = APIRoute.getEvolutionChain(url)
        
        do {
            try requestHandler.request(route: route, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
}

