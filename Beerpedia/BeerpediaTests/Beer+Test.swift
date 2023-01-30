//
//  Beer+Test.swift
//  BeerpediaTests
//
//  Created by Evelyne Suto on 23.01.2023.
//

import Foundation

extension Beer {
    static var testBeer: Beer {
        .init(id: Int.random(in: (0...1000)),
              name: "Beer",
              tagline: "Beer tagline",
              firstBrewed: "08/2022",
              description: "Beer description",
              imageUrl: nil,
              abv: nil,
              ibu: nil,
              targetFG: nil,
              targetOG: nil,
              ebc: nil,
              srm: nil,
              ph: nil,
              attenuationLevel: nil,
              volume: Amount.unitLiter,
              boilVolume: Amount.unitLiter,
              ingredients: Ingredients(malt: [], hops: []),
              brewerTips: nil,
              contributedBy: nil)
    }
}

extension Amount {
    static var unitLiter: Amount { Amount(value: 1, unit: "l") }
}
