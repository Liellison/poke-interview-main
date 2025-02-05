//
//  PokemonListViewViewModel.swift
//  onTopPoke
//
//  Created by Liellison Menezes on 05/02/25.
//

import Foundation
import Network

class PokemonListViewViewModel: ObservableObject {
    @Published var species: [Species] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    private var currentPage = 0
    private let pageSize = 20
    private var isFetching = false
    private let requestHandler: RequestHandling = PokemonRequestHandler()
    
    private let monitor = NWPathMonitor()
    private var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func fetchNextPage() {
        guard !isFetching else { return }
        
        guard isConnected else {
            self.errorMessage = "No internet connection. Please try again later."
            return
        }
        
        isFetching = true
        self.isLoading = true
        
        do {
            try requestHandler.request(route: .getSpeciesList(limit: pageSize, offset: currentPage * pageSize)) { [weak self] (result: Result<SpeciesResponse, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        self?.species.append(contentsOf: response.results)
                        self?.currentPage += 1
                    case .failure(let error):
                        self?.errorMessage = "Error loading data: \(error.localizedDescription)"
                    }
                    self?.isLoading = false  // Finaliza o carregamento
                    self?.isFetching = false
                }
            }
        } catch {
            self.errorMessage = "Error processing request: \(error.localizedDescription)"
            self.isLoading = false
            self.isFetching = false
        }
    }
}

