//
//  Ingredient.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Foundation

struct Ingredient: Codable {
    let name: String
    let amount: Amount
}

struct Ingredients: Codable {
    let malt: [Ingredient]
    let hops: [Ingredient]
}
