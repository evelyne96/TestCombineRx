//
//  Beer.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Foundation

struct Beer: Codable {
    let id: Int
    let name: String
    let tagline: String
    let firstBrewed: String
    let description: String
    let imageUrl: String?
    let abv: Double?
    let ibu: Double?
    let targetFG: Double?
    let targetOG: Double?
    let ebc: Double?
    let srm: Double?
    let ph: Double?
    let attenuationLevel: Double?
    let volume: Amount
    let boilVolume: Amount
    let ingredients: Ingredients
    let brewerTips: String?
    let contributedBy: String?
}
