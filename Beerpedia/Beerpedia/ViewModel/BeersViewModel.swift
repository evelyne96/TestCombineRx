//
//  BeersViewModel.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Combine
import Foundation

enum ViewEvent: Equatable {
    case onLoaded
    case didSelect(_ indexPath: IndexPath)
}

final class BeersViewModel {
    enum State {
        case loading(state: Bool)
        case error(description: String?)
        case dataLoaded(beers: [BeerViewModel])
    }
    
    private let apiClient: BeerAPIClient
    private let coordinator: AppCoordinator
    private var subscriptions = Set<AnyCancellable>()
    
    private var state = PassthroughSubject<State, Never>()
    
    private(set) var viewEvent = PassthroughSubject<ViewEvent, Never>()
    private(set) var isLoading = CurrentValueSubject<Bool, Never>(false)
    private(set) var error = CurrentValueSubject<String?, Never>(nil)
    private(set) var beers = CurrentValueSubject<[BeerViewModel], Never>([])
    let title: String = "Beers"
    
    init(apiClient: BeerAPIClient = BeerAPIClient(),
         coordinator: AppCoordinator = AppCoordinator()) {
        self.apiClient = apiClient
        self.coordinator = coordinator
        
        createSubscriptions()
    }
    
    private func createSubscriptions() {
        viewEvent
            .filter { $0 == .onLoaded }
            .flatMap { [weak self] _ in
                
                self?.state.send(.loading(state: true))
                return self?.apiClient.getBeers() ?? Fail(outputType: [Beer].self, failure: APIError.unknown).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.state.send(.error(description: error.description))
                case .finished:
                    break
                }
            }, receiveValue: {  [weak self] value in
                self?.state.send(.loading(state: false))
                self?.state.send(.error(description: nil))
                self?.state.send(.dataLoaded(beers: value.mapToBeerViewModel()))
            }).store(in: &subscriptions)
        
        state.sink { [weak self] state in
            switch state {
            case .loading(let loading):
                self?.isLoading.send(loading)
            case .error(let description):
                self?.error.send(description)
            case .dataLoaded(let beers):
                self?.beers.send(beers)
            }
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
