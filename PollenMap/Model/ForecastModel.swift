//
//  ForecastModel.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 26.05.2022.
//

import Foundation
import CoreLocation

protocol Model { }

protocol ForecastModelProtocol: Model {
    var forecasts: Forecasts? { get set }
    var allergens: [Allergen] { get set }
    var areaList: [ForecastArea] { get set }
    
    var currentAllergen: Allergen { get set }
    var currentInterval: Interval { get set }
    var currentLocation: CLLocationCoordinate2D { get set }

    func fetchForecasts()
    func getIntervals() -> [Interval]
    func fetchAreaList(for allergen: Allergen, and interval: Interval)
}

class ForecastModel: NSObject, ForecastModelProtocol {
    let loadingGroup = DispatchGroup()
    let networkService = NetworkService()

    var forecasts: Forecasts? = nil {
        didSet {
            allergens = forecasts?.allergens ?? []

        }
    }
    var allergens: [Allergen] = []
    var areaList: [ForecastArea] = []
    
    var currentAllergen: Allergen = "Береза" {
        didSet {
            fetchAreaList(for: currentAllergen, and: currentInterval)
        }
    }
    var currentInterval: Interval = 0 {
        didSet {
            fetchAreaList(for: currentAllergen, and: currentInterval)
        }
    }
    var currentLocation: CLLocationCoordinate2D = .init(latitude: 55.755833, longitude: 37.617222)
}

extension ForecastModel {
    func fetchForecasts() {
        loadingGroup.enter()
        networkService.fetchForecasts { forecastsLoaded in
            self.forecasts = forecastsLoaded
            self.loadingGroup.leave()
        }
        loadingGroup.wait()
    }
    
    func getIntervals() -> [Interval] {
        return forecasts?.interval ?? []
    }
    
    func fetchAreaList(for allergen: Allergen, and interval: Interval) {
        guard let forecasts = forecasts else { return }
        loadingGroup.enter()
        networkService.fetchAreaData(for: forecasts,
                                     and: allergen,
                                     with: interval) { areaList in
//            print("2> areaList: \(areaList)")
            self.areaList = areaList
            self.loadingGroup.leave()
        }
        loadingGroup.wait()
    }
}
