import SwiftUI

/// Details view showing the evolution chain of a Pokémon (WIP)
///
/// It now only shows a placeholder image, make it so that it also shows the evolution chain of the selected Pokémon, in whatever way you think works best.
/// The evolution chain url can be fetched using the endpoint `APIRouter.getSpecies(URL)` (returns type `SpeciesDetails`), and the evolution chain details through `APIRouter.getEvolutionChain(URL)` (returns type `EvolutionChainDetails`).
/// Requires a working `RequestHandler`
import SwiftUI

struct DetailsView: View {
    @StateObject private var viewModel: DetailsViewModel
    
    init(species: Species, service: PokemonServiceProtocol = PokemonService()) {
        _viewModel = StateObject(wrappedValue: DetailsViewModel(species: species, service: service))
    }
    
    var body: some View {
        VStack {
            AsyncImage(url: viewModel.species.imageUrl) { image in
                image.resizable()
                    .scaledToFit()
                    .transition(.opacity.combined(with: .scale))
            } placeholder: {
                ProgressView()
            }
            .frame(width: 200, height: 200)
            
            Text(viewModel.species.name.capitalized)
                .font(.largeTitle)
            
            Divider()
            
            if viewModel.evolutionChain.isEmpty {
                Text("Loading evolutions...")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.evolutionChain, id: \.name) { evo in
                            VStack {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.updateSpecies(evo)
                                    }
                                    viewModel.fetchSpeciesDetails()
                                }) {
                                    AsyncImage(url: evo.imageUrl) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .scaleEffect(viewModel.isAnimating ? 1.2 : 1.0)
                                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.isAnimating)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                }
                                
                                Text(evo.name.capitalized)
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.species.name.capitalized)
        .onAppear {
            viewModel.fetchSpeciesDetails()
        }
    }
}
