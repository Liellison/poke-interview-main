import SwiftUI


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
    @StateObject private var viewModel: PokemonListViewModel
    
    /// Allows dependency injection for testing purposes
    init(service: PokemonServiceProtocol = PokemonService()) {
        _viewModel = StateObject(wrappedValue: PokemonListViewModel(service: service))
    }
    
    var body: some View {
        NavigationView {
            List {
                // Display error message if an error occurs
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Display Pokémon list
                ForEach(viewModel.species, id: \.name) { species in
                    NavigationLink(destination: DetailsView(species: species, service: viewModel.service)) {
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
                        // Load more Pokémon when the last item appears
                        if species == viewModel.species.last {
                            viewModel.fetchNextPage()
                        }
                    }
                }
                
                // Show loading indicator at the bottom
                if viewModel.isLoading {
                    ProgressView("Loading more Pokémon...")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("POKÉMON")
        }
        .onAppear {
            viewModel.fetchNextPage()
        }
    }
}
