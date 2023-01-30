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
    private let apiClient: BeerAPI
    private let beer: Beer
    
    private(set) var viewEvent = PassthroughSubject<ViewEvent, Never>()
    private(set) var image = CurrentValueSubject<UIImage?, Never>(nil)
    private(set) var isDownloading = CurrentValueSubject<Bool, Never>(false)
    
    var name: String { beer.name }
    var firstBrewed: String { beer.firstBrewed }
    var contributedBy: String { beer.contributedBy ?? "" }
    
    init(beer: Beer,
         apiClient: BeerAPI = BeerAPIClient()) {
        self.apiClient = apiClient
        self.beer = beer
    }
    
    var imagePublisher: AnyPublisher<UIImage?, Never> {
        guard image.value == nil,
              let imageURL = beer.imageUrl,
              let url = URL(string: imageURL) else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        isDownloading.send(true)
        
        return apiClient.getImage(url: url)
                        .map { [weak self] in
                            let image = UIImage(data: $0)
                            self?.image.send(image)
                            self?.isDownloading.send(false)
                            return image
                        }
                        .replaceError(with: nil)
                        .eraseToAnyPublisher()
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
