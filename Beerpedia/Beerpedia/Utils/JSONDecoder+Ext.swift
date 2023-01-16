//
//  JSONDecoder+Ext.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Foundation

extension JSONDecoder {
    static var snakeCaseDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
