//
//  ForecastsMapViewPrefs.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 26.06.2022.
//

import UIKit

struct ForecastsMapViewPrefs {
    let lightColor: UIColor = .init(hexString: "#F2D7D9")
    let semiLightColor: UIColor = .init(hexString: "#D3CEDF")
    let semiDarkColor: UIColor = .init(hexString: "#9CB4CC")
    let darkColor: UIColor = .init(hexString: "#748DA6")

    static let shared = ForecastsMapViewPrefs()
}
