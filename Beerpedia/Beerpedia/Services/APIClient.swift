//
//  APIClient.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Foundation
import Combine

enum APIError: Error {
    case unknown
    case invalidRequest
    case invalidData
    case invalidResponse
    case serverError(_ error: String)
    case decodingError(_ error: String)
}

protocol APIClient {
    var urlSession: URLSession { get }
    
    func getData(url: URL?) -> AnyPublisher<Data, APIError>
    func get<T: Decodable>(url: URL?, decoder: JSONDecoder) -> AnyPublisher<T, APIError>
}

extension APIClient {
    func getData(url: URL?) -> AnyPublisher<Data, APIError> {
        guard let url = url else {
            return Fail(error: APIError.invalidRequest).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { data, urlResponse in
                guard let httpResponse = urlResponse as? HTTPURLResponse else { throw APIError.invalidResponse }
                guard (200..<300).contains(httpResponse.statusCode) else { throw APIError.serverError(httpResponse.statusCode.description) }
                guard !data.isEmpty else { throw APIError.invalidData }
                
                return data
            }
            .mapError{ $0 as? APIError ?? .unknown }
            .eraseToAnyPublisher()
    }
    
    func get<T: Decodable>(url: URL?, decoder: JSONDecoder) -> AnyPublisher<T, APIError> {
        return getData(url: url)
            .decode(type: T.self, decoder: decoder)
            .mapError{ $0 as? APIError ?? APIError.decodingError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}
