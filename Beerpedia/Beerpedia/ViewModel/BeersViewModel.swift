//
//  BeersViewModel.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Combine
import Foundation

enum ViewEvent: Equatable {
    case onAppear
    case didSelect(_ indexPath: IndexPath)
}

class BeersViewModel {
    private let apiClient: BeerAPIClient
    private let coordinator: AppCoordinator
    private var subscriptions = Set<AnyCancellable>()
    
    private(set) var viewEvent = PassthroughSubject<ViewEvent, Never>()
    let beers = CurrentValueSubject<[BeerViewModel], Never>([])
    
    init(apiClient: BeerAPIClient = BeerAPIClient(),
         coordinator: AppCoordinator = AppCoordinator()) {
        self.apiClient = apiClient
        self.coordinator = coordinator
        
        createSubscrioptions()
    }
    
    private func createSubscrioptions() {
        viewEvent
            .filter { $0 == .onAppear }
            .loadBeers(apiClient: apiClient)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                let viewModels = $0.mapToBeerViewModel()
                self?.beers.send(viewModels)
            }.store(in: &subscriptions)
        
        viewEvent.sink { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .didSelect(let index):
                let viewModel = self.beers.value[index.row]
                self.coordinator.showDetailsFor(viewModel: viewModel)
            default:
                break
            }
        }.store(in: &subscriptions)
    }
}

private extension Publisher {
    func loadBeers(apiClient: BeerAPIClient) -> AnyPublisher<[Beer], Never> {
        apiClient.getBeers()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

extension Array where Element == Beer {
    func mapToBeerViewModel() -> [BeerViewModel] {
        map { BeerViewModel(beer: $0) }
    }
}

extension Set where Element == AnyCancellable {
    mutating func cancelAll() {
        forEach { $0.cancel() }
        removeAll()
    }
}
