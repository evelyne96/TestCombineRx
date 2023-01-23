//
//  BeerAPIClient.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Foundation
import Combine

enum BeerEndpoints: CustomStringConvertible {
    static let baseURL = URL(string: "https://api.punkapi.com/v2")
    var url: URL? { Self.baseURL?.appending(path: description) }
    
    case beers
    case beer(id: Int)
    
    var description: String {
        switch self {
        case .beers: return "beers"
        case .beer(let id): return "beers/\(id)"
        }
    }
}

final class BeerAPIClient: APIClient {
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
    
    func getBeer(id: Int) -> AnyPublisher<[Beer], APIError> {
        get(url: BeerEndpoints.beer(id: id).url, decoder: JSONDecoder.snakeCaseDecoder)
    }
}
