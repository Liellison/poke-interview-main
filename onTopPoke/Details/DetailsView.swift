import SwiftUI

/// Details view showing the evolution chain of a Pokémon (WIP)
///
/// It now only shows a placeholder image, make it so that it also shows the evolution chain of the selected Pokémon, in whatever way you think works best.
/// The evolution chain url can be fetched using the endpoint `APIRouter.getSpecies(URL)` (returns type `SpeciesDetails`), and the evolution chain details through `APIRouter.getEvolutionChain(URL)` (returns type `EvolutionChainDetails`).
/// Requires a working `RequestHandler`
struct DetailsView: View {
    @State private var species: Species
    @State private var evolutionChain: [Species] = []
    @State private var isAnimating = false
    
    init(species: Species) {
        _species = State(initialValue: species)
    }
    
    var body: some View {
        VStack {
            AsyncImage(url: species.imageUrl) { image in
                image.resizable()
                    .scaledToFit()
                    .transition(.opacity.combined(with: .scale))
            } placeholder: {
                ProgressView()
            }
            .frame(width: 200, height: 200)
            
            Text(species.name.capitalized)
                .font(.largeTitle)
            
            Divider()
            
            if evolutionChain.isEmpty {
                Text("Loading evolutions...")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(evolutionChain, id: \.name) { evo in
                            VStack {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.species = evo
                                        self.evolutionChain = []
                                    }
                                    fetchSpeciesDetails()
                                }) {
                                    AsyncImage(url: evo.imageUrl) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isAnimating)
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
        .navigationTitle(species.name.capitalized)
        .onAppear {
            fetchSpeciesDetails()
        }
    }
    
    private func fetchSpeciesDetails() {
        let request = APIRoute.getSpecies(URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(species.name)")!).asRequest()
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(SpeciesDetails.self, from: data)
                fetchEvolutionChain(from: decodedResponse.evolutionChain.url)
            } catch {
                print("Error fetching species details:", error)
            }
        }.resume()
    }
    
    private func fetchEvolutionChain(from url: URL) {
        let request = APIRoute.getEvolutionChain(url).asRequest()
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(EvolutionChainDetails.self, from: data)
                let evolutions = decodedResponse.chain.getAllEvolutions()
                
                DispatchQueue.main.async {
                    self.evolutionChain = evolutions
                }
            } catch {
                print("Error searching for evolutionary chain:", error)
            }
        }.resume()
    }
}
