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
    @StateObject private var viewModel = PokemonListViewViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
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
