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
    enum State {
        case loading(state: Bool)
        case error(description: String?)
        case dataLoaded(beers: [BeerViewModel])
    }
    
    private let apiClient: BeerAPIClient
    private var subscriptions = Set<AnyCancellable>()
    
    private var state = PassthroughSubject<State, Never>()
    
    private(set) var viewEvent = PassthroughSubject<ViewEvent, Never>()
    private(set) var isLoading = CurrentValueSubject<Bool, Never>(false)
    private(set) var error = CurrentValueSubject<String?, Never>(nil)
    private(set) var beers = CurrentValueSubject<[BeerViewModel], Never>([])
    
    init(apiClient: BeerAPIClient = BeerAPIClient()) {
        self.apiClient = apiClient
        
        viewEvent
            .filter { $0 == .onAppear }
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
