//
//  ForecastArea.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 20.05.2022.
//

import Foundation

/**
 https://github.com/Leaflet/Leaflet/blob/main/docs/reference.html
 <p>Additionally, you can pass a multi-dimensional array to represent a MultiPolygon shape.</p>
    var latlngs = [
      [ // first polygon
        [[37, -109.05],[41, -109.03],[41, -102.05],[37, -102.04]], // outer ring
        [[37.29, -108.58],[40.71, -108.58],[40.71, -102.50],[37.29, -102.50]] // hole
      ],
      [ // second polygon
        [[41, -111.03],[45, -111.04],[45, -104.05],[41, -104.05]]
      ]
    ];
 */
/**
     "latlngs": [],
     "color": "#009900",
     "opacity": 1,
     "weight": 1,
     "fillColor": "#009900",
     "fillOpacity": 0.5
 */

typealias Coordinate = [Double]
typealias Polygon = [Coordinate]
typealias MultiPolygon = [Polygon]

struct ForecastArea: Codable {
    let latlngs: [MultiPolygon]
    let color: String
    let opacity: Double
    let weight: Double
    let fillColor: String
    let fillOpacity: Double
}

extension ForecastArea {
    
    enum CodingKeys: CodingKey {
        case latlngs
        case color
        case opacity
        case weight
        case fillColor
        case fillOpacity
    }
    
}
