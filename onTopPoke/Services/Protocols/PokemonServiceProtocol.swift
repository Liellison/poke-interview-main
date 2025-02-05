//
//  PokemonServiceProtocol.swift
//  onTopPoke
//
//  Created by Liellison Menezes on 05/02/25.
//

import Foundation

protocol PokemonServiceProtocol {
    func fetchPokemonList(limit: Int, offset: Int, completion: @escaping (Result<SpeciesResponse, Error>) -> Void)
    func fetchSpeciesDetails(for speciesName: String, completion: @escaping (Result<SpeciesDetails, Error>) -> Void)
    func fetchEvolutionChain(from url: URL, completion: @escaping (Result<EvolutionChainDetails, Error>) -> Void)
}

