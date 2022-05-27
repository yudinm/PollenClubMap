//
//  MapService.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 23.05.2022.
//

import Foundation
import GoogleMaps

protocol MapServiceProtocol: Service {
    func configureMapsSDK()
    
    func getGMPath(with coordinates: Polygon) -> GMSMutablePath
    func getGMPolygon(with path: GMSPath, and area: ForecastArea) -> GMSPolygon
}

class MapService: NSObject, MapServiceProtocol {
    static let apiKey = "***REMOVED***"
    var polygons:[GMSPolygon] = []
}

extension MapService {
    func configureMapsSDK() {
        GMSServices.provideAPIKey(MapService.apiKey)
    }
}

extension MapService {
    func getGMPath(with coordinates: Polygon) -> GMSMutablePath {
        let path = GMSMutablePath()
        coordinates.forEach { latlng in
            guard let lat = latlng.first else { return }
            guard let lng = latlng.last else { return }
            path.add(.init(latitude: lat, longitude: lng))
        }
        return path
    }
    
    func getGMPolygon(with path: GMSPath, and area: ForecastArea) -> GMSPolygon {
        let polygon = GMSPolygon(path: path)
        polygon.fillColor =
            .init(hexString: area.fillColor).withAlphaComponent(area.fillOpacity)
        polygon.strokeColor = .init(hexString: area.color)
        polygon.strokeWidth = 1 // TODO: fix with some prefs

        return polygon
    }
}
