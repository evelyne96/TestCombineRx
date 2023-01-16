//
//  BeersViewModel.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Combine
import Foundation

class BeerListViewModel: ObservableObject {
    private let apiClient = BeerAPIClient()
    private var cancellables = Set<AnyCancellable>()
    var beers: [Beer] = []
    
    func loadBeers() {
        cancellables.cancelAll()
        
        apiClient.getBeers()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 {
                    debugPrint(error)
                }
            }, receiveValue: { [weak self] in
                self?.beers = $0
            })
            .store(in: &cancellables)
    }
}

private extension Set where Element == AnyCancellable {
    mutating func cancelAll() {
        forEach { $0.cancel() }
        removeAll()
    }
}
