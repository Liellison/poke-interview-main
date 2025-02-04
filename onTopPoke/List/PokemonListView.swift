import SwiftUI
import Network

/// Main view showing the list of Pokémon
///
/// The tableview is setup already. but fetching from a fake request handler, returning fake Pokémon, and showing a local image
/// Goal:
/// - Use your own `RequestHandler` to fetch Pokémon from the backend
/// - Display the pokemon name and image (fetched remotely)
/// - Implement pagination to simulate infinite scrolling
/// - Error handling
///
/// Not required, but feel free to improve/reorganize the ViewController however you like.
struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.species, id: \.name) { species in
                    NavigationLink(destination: DetailsView(species: species)) {
                        HStack {
                            AsyncImage(url: species.imageUrl) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 50, height: 50)
                            
                            Text(species.name.capitalized)
                        }
                    }
                    .onAppear {
                        if species.name == viewModel.species.last?.name {
                            viewModel.fetchNextPage()
                        }
                    }
                }
            }
            .navigationTitle("POKÉMON")
        }
        .onAppear {
            viewModel.fetchNextPage()
        }
    }
}

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

