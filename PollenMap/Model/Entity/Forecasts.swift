//
//  Forecasts.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 20.05.2022.
//

import Foundation

typealias Allergen = String
typealias Interval = Int

struct Forecasts: Codable {
    let allergens: [Allergen]
    let interval: [Interval]
    let intervalPath: [Interval: String]
    let root: String
}

extension Forecasts {
    
    enum CodingKeys: CodingKey {
        case allergens
        case interval
        case intervalPath
        case root
    }
    
}
