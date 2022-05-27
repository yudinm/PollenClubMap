//
//  ForecastModel.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 26.05.2022.
//

import Foundation

protocol Model { }

protocol ForecastModelProtocol: Model {
    var forecasts: Forecasts? { get set }
    var allergens: [Allergen] { get set }
    var areaList: [ForecastArea] { get set }
    
    var selectedAllergen: Allergen { get set }
    var selectedInterval: Interval { get set }

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
    
    var selectedAllergen: Allergen = "Береза" {
        didSet {
            fetchAreaList(for: selectedAllergen, and: selectedInterval)
        }
    }
    var selectedInterval: Interval = 0 {
        didSet {
            fetchAreaList(for: selectedAllergen, and: selectedInterval)
        }
    }
    
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
