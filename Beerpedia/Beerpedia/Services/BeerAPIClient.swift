//
//  BeerAPIClient.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Foundation
import Combine

enum BeerEndpoints: String {
    static let baseURL = URL(string: "https://api.punkapi.com/v2")
    var url: URL? { Self.baseURL?.appending(path: rawValue) }
    
    case beers = "beers"
}

class BeerAPIClient: APIClient {
    let urlSession: URLSession
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func getBeers() -> AnyPublisher<[Beer], APIError> {
        get(url: BeerEndpoints.beers.url, decoder: JSONDecoder.snakeCaseDecoder)
    }
    
    func getImage(url: URL) -> AnyPublisher<Data, APIError> {
        getData(url: url)
    }
}
