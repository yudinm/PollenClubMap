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
    var intervalsList: [Interval] { get }

    func fetchForecasts()
    func getIntervals() -> [Interval]
    func fetchAreaList()
}

open class ForecastModel: NSObject, ForecastModelProtocol {
    private let networkService = NetworkService()

    internal var forecasts: Forecasts? = nil {
        didSet {
            allergens = forecasts?.allergens ?? []
            currentIntervalIndex = (forecasts?.interval[0] ?? 0) * (-1)
            intervalsList = getIntervals()
        }
    }
    var allergens: [Allergen] = []
    var areaList: [ForecastArea] = []
    
    var currentAllergen: Allergen = "Береза" {
        didSet {
            fetchAreaList()
        }
    }
    internal var currentInterval: Interval = 0
    var currentIntervalIndex: Int = 0 {
        didSet {
            if (intervalsList.count == 0) { currentInterval = 0; return }
            if (currentIntervalIndex < 0) { currentIntervalIndex = 0 }
            if (currentIntervalIndex >= intervalsList.count) { currentIntervalIndex = intervalsList.count-1 }
            self.currentInterval = self.intervalsList[self.currentIntervalIndex]
        }
    }
    var currentLocation: CLLocationCoordinate2D = .init(latitude: 55.755833, longitude: 37.617222)
    lazy var intervalsList: [Interval] = []
    private let fetchingForecastsQueue = OperationQueue()
    private let fetchingAreasQueue = OperationQueue()
    var fetchedAreas: [Interval: FetchAreaListOperation] = [:]
}

extension ForecastModel {
    func fetchForecasts() {
        fetchingForecastsQueue.cancelAllOperations()
        let fetchForecastsOperation = FetchForecastsOperation(for: networkService)
        fetchForecastsOperation.completionBlock = {
            if fetchForecastsOperation.isCancelled { return }
            self.forecasts = fetchForecastsOperation.forecasts
        }
        fetchingForecastsQueue.addOperation(fetchForecastsOperation)
    }
    
    /**
         "interval": [ -72, 96, 1] -> [-72,-71,...,0,1,...,95,96]
     */
    func getIntervals() -> [Interval] {
        guard let intervalsEdges = forecasts?.interval else { return [] }
        var intervals = [Interval]()
        for i in intervalsEdges[0]...intervalsEdges[1] {
            intervals.append(i)
        }
        return intervals
    }
    
    func fetchAreaList() {
        guard let forecasts = forecasts else { return }
        fetchingAreasQueue.cancelAllOperations()
        let fetchingArea = FetchAreaListOperation(for: currentAllergen, and: currentInterval, and: forecasts, and: networkService)
        fetchedAreas[currentInterval] = fetchingArea
        fetchingAreasQueue.addOperation(fetchingArea)
    }
}

class FetchForecastsOperation: Operation {
    let networkService: NetworkService
    let loadingGroup = DispatchGroup()
    var forecasts: Forecasts?
    
    init(for networkService: NetworkService) {
        self.networkService = networkService
        super.init()
    }
    
    override func main() {
        if isCancelled { return }
        self.networkService.fetchForecasts { forecastsLoaded in
            self.forecasts = forecastsLoaded
            self.loadingGroup.leave()
        }
        loadingGroup.enter()
        loadingGroup.wait()
    }
}

class FetchAreaListOperation: Operation {
    let allergen: Allergen
    let interval: Interval
    let forecasts: Forecasts
    let networkService: NetworkService
    let loadingGroup = DispatchGroup()
    var areaList: [ForecastArea]?
    
    init(for allergen: Allergen, and interval: Interval, and forecasts: Forecasts, and networkService: NetworkService) {
        self.allergen = allergen
        self.interval = interval
        self.forecasts  = forecasts
        self.networkService = networkService
        super.init()
    }
    
    override func main() {
        if isCancelled { return }
        networkService.fetchAreaData(for: forecasts, and: allergen, with: interval) { areaList in
            self.areaList = areaList
            self.loadingGroup.leave()
        }
        loadingGroup.enter()
        loadingGroup.wait()
    }
}
