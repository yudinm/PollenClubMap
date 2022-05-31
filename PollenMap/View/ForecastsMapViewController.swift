//
//  ForecastsMapViewController.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 27.05.2022.
//

import UIKit
import SnapKit
import GoogleMaps

class ForecastsMapViewController: UIViewController {
    
    enum CameraControls {
        case zoomInButton
        case zoomOutButton
        case centerLocationButton
    }
    
    enum ForecastControls {
        case currentAllergenButton
        case nextIntervalButton
        case prevIntervalButton
    }
    
    enum LoadingForecastConrols {
        case reloadButton
    }
        
    let cameraControls: [CameraControls: UIView] = [
        .zoomInButton: UIButton(),
        .zoomOutButton: UIButton(),
        .centerLocationButton: UIButton()
    ]
    
    let forecastControls: [ForecastControls: UIView] = [
        .currentAllergenButton: UIButton(),
        .nextIntervalButton: UIButton(),
        .prevIntervalButton: UIButton()
    ]
    
    let loadingForecastControls: [LoadingForecastConrols: UIView] = [
        .reloadButton: UIButton()
    ]
    
    let mapService = MapService()
    let mapView: GMSMapView = GMSMapView.map(withFrame: .zero, camera: .init())
    var model: ForecastModel! = ForecastModel()
    var pickers: ForecastsMapPickersViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.fetchForecasts()
        addMapView()
        addControls()
    }
}

extension ForecastsMapViewController {
    func addMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mapView.animate(toZoom: 5)
    }
}

extension ForecastsMapViewController {
    func reloadData() {
        model.fetchAreaList(for: model.currentAllergen, and: model.currentInterval)
        model.areaList.forEach { area in
            area.latlngs.forEach { polygons in
                polygons.forEach { polygon in
                    let path = mapService.getGMPath(with: polygon)
//                    print("path encoded: \(path.encodedPath()) \n")
                    let polygon = mapService.getGMPolygon(with: path, and: area)
                    polygon.map = mapView
                }
            }
        }
    }
}

extension ForecastsMapViewController {
    func addControls() {
        addCameraControls()
        addForecastControls()
        addLoadingForecastConrols()
    }
    
    func addCameraControls() {
        guard let zoomInButton = cameraControls[.zoomInButton] as? UIButton else { return }
        zoomInButton.setTitle("＋", for: .normal)
        zoomInButton.titleLabel?.font = .systemFont(ofSize: 44)
        zoomInButton.backgroundColor = .lightGray.withAlphaComponent(0.6)
        zoomInButton.layer.cornerRadius = 22.0
        view.addSubview(zoomInButton)
        zoomInButton.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(44)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview().offset(-44-8)
        }
        
        zoomInButton.addTarget(self, action: #selector(handleCameraButtons), for: .touchUpInside)
                
        guard let zoomOutButton = cameraControls[.zoomOutButton] as? UIButton else { return }
        zoomOutButton.setTitle("－", for: .normal)
        zoomOutButton.titleLabel?.font = .systemFont(ofSize: 44)
        zoomOutButton.backgroundColor = .lightGray.withAlphaComponent(0.6)
        zoomOutButton.layer.cornerRadius = 22.0
        view.addSubview(zoomOutButton)
        zoomOutButton.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(44)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(zoomInButton.snp.bottom).offset(16)
        }
        
        zoomOutButton.addTarget(self, action: #selector(handleCameraButtons), for: .touchUpInside)

        guard let centerLocationButton = cameraControls[.centerLocationButton] as? UIButton else { return }
        centerLocationButton.setTitle("◉", for: .normal)
        centerLocationButton.titleLabel?.font = .systemFont(ofSize: 44)
        centerLocationButton.backgroundColor = .lightGray.withAlphaComponent(0.6)
        centerLocationButton.layer.cornerRadius = 22.0
        view.addSubview(centerLocationButton)
        centerLocationButton.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(44)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-88)
        }
        
        centerLocationButton.addTarget(self, action: #selector(handleCameraButtons), for: .touchUpInside)

    }
    
    func addForecastControls() {
        guard let currentAllergenButton = forecastControls[.currentAllergenButton] as? UIButton else { return }
        currentAllergenButton.setTitle(model.currentAllergen, for: .normal)
        currentAllergenButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        currentAllergenButton.backgroundColor = .lightGray.withAlphaComponent(0.9)
        currentAllergenButton.layer.cornerRadius = 4.0
        view.addSubview(currentAllergenButton)
        currentAllergenButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(8)
            make.width.equalTo(66).priority(.medium)
        }
        currentAllergenButton.addTarget(self, action: #selector(handleForecastButtons), for: .touchUpInside)


    }
    
    func addLoadingForecastConrols() {
        guard let reloadButton = loadingForecastControls[.reloadButton] as? UIButton else { return }
        reloadButton.setTitle("Загрузить", for: .normal)
        reloadButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        reloadButton.backgroundColor = .lightGray.withAlphaComponent(0.9)
        reloadButton.layer.cornerRadius = 4.0
        view.addSubview(reloadButton)
        reloadButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(8)
            make.width.equalTo(66).priority(.medium)
        }
        reloadButton.addTarget(self, action: #selector(handleLoadingButtons), for: .touchUpInside)

    }
}

extension ForecastsMapViewController {
    
    @objc func handleCameraButtons(_ sender: UIButton) {
        if (sender.isEqual(cameraControls[.zoomInButton])) {
            mapView.animate(toZoom: mapView.camera.zoom+1)
        }
        if (sender.isEqual(cameraControls[.zoomOutButton])) {
            mapView.animate(toZoom: mapView.camera.zoom-1)
        }
        if (sender.isEqual(cameraControls[.centerLocationButton])) {
            mapView.animate(toLocation: model.currentLocation)
        }
    }
    
    @objc func handleForecastButtons(_ sender: UIButton) {
        if (sender.isEqual(forecastControls[.currentAllergenButton])) {
            pickers = ForecastsMapPickersViewController()
            pickers.model = model
            pickers.currentPickerType = .currentAllergenPicker
            pickers.modalPresentationStyle = .custom
            pickers.transitioningDelegate = self
            pickers.completion = {
                guard let currentAllergenButton = self.forecastControls[.currentAllergenButton] as? UIButton else { return }
                currentAllergenButton.setTitle(self.model.currentAllergen, for: .normal)
            }
            present(pickers, animated: true)


        }
    }
    @objc func handleLoadingButtons(_ sender: UIButton) {
        if (sender.isEqual(loadingForecastControls[.reloadButton])) {
            mapView.clear()
            reloadData()
        }
    }
}

extension ForecastsMapViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class PresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        let ratio = 0.29
        return CGRect(x: 0, y: bounds.height * (1 - ratio), width: bounds.width, height: bounds.height * ratio)
    }
}
