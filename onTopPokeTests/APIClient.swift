//
//  APIClient.swift
//  onTopPokeTests
//
//  Created by Liellison Menezes on 04/02/25.
//

import Foundation

struct Pokemon: Decodable {
    let id: Int
    let name: String
    let evolutionChain: [Int]
}

enum APIError: Error {
    case networkError(Error)
    case decodingError(Error)
}

protocol APIClientProtocol {
    func fetchPokemon(completion: @escaping (Result<Pokemon, APIError>) -> Void)
}

class APIClient: APIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchPokemon(completion: @escaping (Result<Pokemon, APIError>) -> Void) {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon-species")!
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            guard let data = data else {
                completion(.failure(.networkError(NSError(domain: "No data", code: 0, userInfo: nil))))
                return
            }
            do {
                let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                completion(.success(pokemon))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}

