//
//  Forecasts.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 20.05.2022.
//

import Foundation

struct Forecasts: Codable { // ??? parse container dictionary
    let allergens: [String]
    let interval: [Int]
    let intervalPath: [Int: String]
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
