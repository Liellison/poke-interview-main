import Foundation

struct PokemonRequestError: Error {}

/// This is RequestHandling implementation returns a hardcoded list of Species.
///
/// This is to be replaced by a proper implementation that actually makes the network call given the APIRoute, parses the response, and returns the resulting object.
class PokemonRequestHandler: RequestHandling {
    func request<T: Decodable>(route: APIRoute, completion: @escaping (Result<T, Error>) -> Void) throws {
        let request = route.asRequest()

        // Fazer a requisição usando URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(PokemonRequestError()))
                return
            }

            do {
                // Decodificar a resposta para o tipo esperado
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

