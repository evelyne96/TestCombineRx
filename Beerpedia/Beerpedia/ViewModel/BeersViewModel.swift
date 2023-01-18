//
//  BeersViewModel.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Combine
import Foundation

enum ViewEvent {
    case onAppear
}

final class BeerListViewModel {
    private let apiClient: BeerAPIClient
    private var subscriptions = Set<AnyCancellable>()
    
    private(set) var viewEvent = PassthroughSubject<ViewEvent, Never>()
    let beers = CurrentValueSubject<[BeerViewModel], Never>([])
    
    init(apiClient: BeerAPIClient = BeerAPIClient()) {
        self.apiClient = apiClient
        
        viewEvent
            .filter { $0 == .onAppear }
            .loadBeers(apiClient: apiClient)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                let viewModels = $0.mapToBeerViewModel()
                self?.beers.send(viewModels)
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
