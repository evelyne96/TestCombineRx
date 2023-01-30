//
//  MockBeerAPI.swift
//  BeerpediaTests
//
//  Created by Evelyne Suto on 20.01.2023.
//

import Combine
import Foundation

class MockBeerAPIClient: BeerAPI {
    enum APICalls: Equatable {
        case getBeers
        case getBeer(Int)
        case getImage
    }
    
    let urlSession: URLSession
    var calls: [APICalls] = []
    var beersResult: Result<[Beer], APIError>? = .failure(.unknown)
    var imageResult: Result<Data, APIError>? = .failure(.unknown)
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func getBeers() -> AnyPublisher<[Beer], APIError> {
        guard let beersResult else {
            return Fail(error: APIError.unknown).eraseToAnyPublisher()
        }
        
        calls.append(.getBeers)

        switch beersResult {
        case .success(let beers):
            return Just(beers).setFailureType(to: APIError.self)
                              .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func getImage(url: URL) -> AnyPublisher<Data, APIError> {
        guard let imageResult else {
            return Fail(error: APIError.unknown).eraseToAnyPublisher()
        }
        
        calls.append(.getImage)
        
        switch imageResult {
        case .success(let imageData):
            return Just(imageData).setFailureType(to: APIError.self)
                                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func getBeer(id: Int) -> AnyPublisher<Beer, APIError> {
        guard let beersResult else {
            return Fail(error: APIError.unknown).eraseToAnyPublisher()
        }
        
        calls.append(.getBeer(id))
        
        switch beersResult {
        case .success(let beers):
            return Just(beers.first!).setFailureType(to: APIError.self)
                                     .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
