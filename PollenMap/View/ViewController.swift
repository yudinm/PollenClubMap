//
//  ViewController.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 19.05.2022.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    let mapService = MapService()
    let forecastModel = ForecastModel()
    var mapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMapView()
        
        forecastModel.fetchForecasts()
        forecastModel.selectedAllergen = "Ольха"
        
        forecastModel.loadingGroup.enter()
        forecastModel.areaList.forEach { area in
            area.latlngs.forEach { polygons in
                polygons.forEach { polygon in
                    let path = mapService.getGMPath(with: polygon)
//                    print("path encoded: \(path.encodedPath()) \n")
                    let polygon = mapService.getGMPolygon(with: path, and: area)
                    polygon.map = mapView
                }
            }
        }
        forecastModel.loadingGroup.leave()
    }


    func addMapView() {
        // 55.755833, 37.617222
        let camera = GMSCameraPosition.camera(withLatitude: 55.755833, longitude: 37.617222, zoom: 1.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)
    }
}

