import UIKit

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
class ListViewController: UIViewController {
    /// TODO, replace with your own `RequestHandler`
    private let requestHandler: RequestHandling = FakeRequestHandler()

    private var species: [Species] = []

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "POKéMON"

        setupViews()
        fetchSpecies()
    }

    private func setupViews() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
    }

    private func fetchSpecies() {
        do {
            // TODO Consider pagination
            try requestHandler.request(route: .getSpeciesList(limit: 20, offset: 0)) { [weak self] (result: Result<SpeciesResponse, Error>) -> Void in
                switch result {
                case .success(let response):
                    self?.didFetchSpecies(response: response)
                case .failure:
                    print("TODO handle network failures")
                }
            }
        } catch {
            print("TODO handle request handling failures failures")
        }
    }

    private func didFetchSpecies(response: SpeciesResponse) {
        species = response.results
        tableView.reloadData()
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return species.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = species[indexPath.row].name

        // TODO Fetch the image remotely, based on the Pokémon ID ("list index + 1")
        // TODO This requires `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/{species_id}.png`
        cell.imageView?.image = UIImage(named: "PlaceholderImage")
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let viewController = DetailsViewController(species: species[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
    }
}
