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

class BeerListViewModel {
    private let apiClient: BeerAPIClient
    private var subscriptions = Set<AnyCancellable>()
    
    private(set) var viewEvent = PassthroughSubject<ViewEvent, Never>()
    let beers = CurrentValueSubject<[BeerViewModel], Never>([])
    
    init(apiClient: BeerAPIClient = BeerAPIClient()) {
        self.apiClient = apiClient
                
        viewEvent.filter { $0 == .onAppear }
            .sink { [weak self] _ in
                self?.loadBeers()
            }
            .store(in: &subscriptions)
    }
    
    private func loadBeers() {
        subscriptions.cancelAll()
        
        apiClient.getBeers()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 {
                    debugPrint(error)
                }
            }, receiveValue: { [weak self] in
                let viewModels = $0.mapToBeerViewModel()
                self?.beers.send(viewModels)
            })
            .store(in: &subscriptions)
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
