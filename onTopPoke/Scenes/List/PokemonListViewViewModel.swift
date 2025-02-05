//
//  PokemonListViewViewModel.swift
//  onTopPoke
//
//  Created by Liellison Menezes on 05/02/25.
//

import Foundation
import Network

class PokemonListViewModel: ObservableObject {
    @Published var species: [Species] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var currentPage = 0
    private let pageSize = 20
    private var isFetching = false
    let service: PokemonServiceProtocol
    
    private let monitor = NWPathMonitor()
    private var isConnected = true
    
    init(service: PokemonServiceProtocol) {
        self.service = service
        
        // Monitor network connectivity
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    /// Fetches the next page of Pokémon from the backend
    func fetchNextPage() {
        guard !isFetching else { return }
        
        guard isConnected else {
            self.errorMessage = "No internet connection. Please try again later."
            return
        }
        
        isFetching = true
        isLoading = true
        
        service.fetchPokemonList(limit: pageSize, offset: currentPage * pageSize) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.species.append(contentsOf: response.results)
                    self?.currentPage += 1
                case .failure(let error):
                    self?.errorMessage = "Error loading data: \(error.localizedDescription)"
                }
                self?.isLoading = false
                self?.isFetching = false
            }
        }
    }
}
