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
    case invalidData
    case serverError(_ error: String)
    case decodingError(_ error: String)
}

protocol APIClient {
    var urlSession: URLSession { get }
    
    func getData(url: URL) -> AnyPublisher<Data, APIError>
    func get<T: Decodable>(url: URL, decoder: JSONDecoder) -> AnyPublisher<T, APIError>
}

extension APIClient {
    func getData(url: URL) -> AnyPublisher<Data, APIError> {
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { data, urlResponse in
                guard !data.isEmpty else { throw APIError.invalidData }
                if let httpResponse = urlResponse as? HTTPURLResponse,
                    !(200..<300).contains(httpResponse.statusCode) {
                    throw APIError.serverError(httpResponse.statusCode.description)
                }
                
                return data
            }
            .mapError{ $0 as? APIError ?? .unknown }
            .eraseToAnyPublisher()
    }
    
    func get<T: Decodable>(url: URL, decoder: JSONDecoder) -> AnyPublisher<T, APIError> {
        return getData(url: url)
            .decode(type: T.self, decoder: decoder)
            .mapError{ APIError.decodingError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}
