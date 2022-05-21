//
//  ViewController.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 19.05.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingGroup = DispatchGroup()
        let networkService = NetworkService()
        var loadedForecasts: Forecasts!
        loadingGroup.enter()
        networkService.fetchForecasts { forecasts in
            print("1> forecasts: \(forecasts)")
            loadedForecasts = forecasts
            loadingGroup.leave()
        }
        loadingGroup.wait()
        loadingGroup.enter()
        networkService.fetchAreaData(for: loadedForecasts,
                                     and: "Береза",
                                     with: 0) { areaList in
            print("2> areaList: \(areaList)")
            loadingGroup.leave()
        }
    }


}

