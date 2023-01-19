//
//  BeerViewModel.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Combine
import Foundation
import UIKit

final class BeerViewModel {
    private let apiClient: BeerAPIClient
    private var subscriptions = Set<AnyCancellable>()
    private let beer: Beer
    
    private(set) var viewEvent = PassthroughSubject<ViewEvent, Never>()
    private(set) var image = CurrentValueSubject<UIImage?, Never>(nil)
    private(set) var isDownloading = CurrentValueSubject<Bool, Never>(false)
    
    var name: String { beer.name }
    var firstBrewed: String { beer.firstBrewed }
    var contributedBy: String { beer.contributedBy ?? "" }
    
    init(beer: Beer,
         apiClient: BeerAPIClient = BeerAPIClient()) {
        self.apiClient = apiClient
        self.beer = beer
        
        viewEvent.filter{ $0 == .onLoaded}
            .sink { [weak self] _ in
                self?.loadImage()
            }.store(in: &subscriptions)
    }
    
    private func loadImage() {
        guard !isDownloading.value,
              let imageURL = beer.imageUrl,
              let url = URL(string: imageURL) else {
            return
        }
        
        subscriptions.cancelAll()
        isDownloading.send(true)
        apiClient.getImage(url: url)
            .map { UIImage(data: $0) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.image.send($0)
                self?.isDownloading.send(false)
            }
            .store(in: &subscriptions)
    }
}

extension BeerViewModel: Hashable {
    static func == (lhs: BeerViewModel, rhs: BeerViewModel) -> Bool {
        lhs.beer.id == rhs.beer.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(beer.id)
    }
}
