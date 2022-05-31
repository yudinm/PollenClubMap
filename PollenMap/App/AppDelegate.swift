//
//  AppDelegate.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 19.05.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let mapService = MapService()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        mapService.configureMapsSDK()
        
        let initialViewController = ForecastsMapViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else {
            return false
        }
//        let forecastsVC = ForecastsMapViewController()
//        initialViewController.setViewControllers([forecastsVC], animated: false)

        window.rootViewController = initialViewController
        window.makeKeyAndVisible()
        return true
    }

}

