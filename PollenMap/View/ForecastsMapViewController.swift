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
    }
    
    enum LoadingForecastConrols {
        case reloadButton
    }
        
    lazy var cameraControls: [CameraControls: UIView] = [
        .zoomInButton: UIButton(),
        .zoomOutButton: UIButton(),
        .centerLocationButton: UIButton()
    ]
    
    lazy var forecastControls: [ForecastControls: UIView] = [
        .currentAllergenButton: UIButton()
    ]
    
    lazy var loadingForecastControls: [LoadingForecastConrols: UIView] = [
        .reloadButton: UIButton()
    ]
    
    lazy var mapService = MapService()
    lazy var mapView: GMSMapView = GMSMapView.map(withFrame: .zero, camera: .init())
    var model: ForecastModel = ForecastModel()
    var pickers: ForecastsMapPickersViewController!
    lazy var playerControls = ForecastsPlayerViewController()
    lazy var currentIntervalLabel = PaddingLabel()
    lazy var loadingSpinner = UIActivityIndicatorView(style: .large)
    lazy var timer = Timer()

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
        mapView.animate(toZoom: 7)
    }
}

extension ForecastsMapViewController {
    func reloadData() {
        loadingSpinner.startAnimating()
        model.fetchAreaList()
        guard let fetchingArea = model.fetchedAreas[model.currentInterval] else { return }
        fetchingArea.completionBlock = {
            if fetchingArea.isCancelled { return }
            DispatchQueue.main.async {
                self.mapView.clear()
                guard let areaList = fetchingArea.areaList else { return }
                areaList.forEach { area in
                    guard let fills = area.latlngs.first else { return }
                        fills.forEach { polygon in
                            let path = self.mapService.getGMPath(with: polygon)
        //                    print("path encoded: \(path.encodedPath()) \n")  // TODO: add some cache
                            let polygon = self.mapService.getGMPolygon(with: path, and: area)
                            polygon.map = self.mapView
                            guard let holes = area.latlngs.last else { return }
                            var holePaths = [GMSPath]()
                            holes.forEach { hole in
                                let holePath = self.mapService.getGMPath(with: hole)
                                holePaths.append(holePath)
                            }
                            polygon.holes = holePaths
                            
                        }
                }
                self.loadingSpinner.stopAnimating()
            }
        }

//        print(">>> reloadDat \(model.currentInterval)")
        let date = Date().advanced(by: TimeInterval(model.currentInterval * 60 * 60))
        let formatter = DateFormatter() // TODO: fix with shared formatter
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        currentIntervalLabel.text = formatter.string(from: date)
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
        zoomInButton.backgroundColor = ForecastsMapViewPrefs.shared.darkColor
        zoomInButton.layer.cornerRadius = 22.0
        zoomInButton.setImage(.init(systemName: "plus"), for: .normal)
        zoomInButton.contentHorizontalAlignment = .fill
        zoomInButton.contentVerticalAlignment = .fill
        zoomInButton.imageView?.contentMode = .scaleAspectFit
        zoomInButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        zoomInButton.tintColor = ForecastsMapViewPrefs.shared.lightColor
        view.addSubview(zoomInButton)
        zoomInButton.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(44)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview().offset(-44-8)
        }
        
        zoomInButton.addTarget(self, action: #selector(handleCameraButtons), for: .touchUpInside)
                
        guard let zoomOutButton = cameraControls[.zoomOutButton] as? UIButton else { return }
        zoomOutButton.backgroundColor = ForecastsMapViewPrefs.shared.darkColor
        zoomOutButton.layer.cornerRadius = 22.0
        zoomOutButton.setImage(.init(systemName: "minus"), for: .normal)
        zoomOutButton.contentHorizontalAlignment = .fill
        zoomOutButton.contentVerticalAlignment = .fill
        zoomOutButton.imageView?.contentMode = .scaleAspectFit
        zoomOutButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        zoomOutButton.tintColor = ForecastsMapViewPrefs.shared.lightColor
        view.addSubview(zoomOutButton)
        zoomOutButton.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(44)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(zoomInButton.snp.bottom).offset(16)
        }
        
        zoomOutButton.addTarget(self, action: #selector(handleCameraButtons), for: .touchUpInside)

        guard let centerLocationButton = cameraControls[.centerLocationButton] as? UIButton else { return }
        centerLocationButton.backgroundColor = ForecastsMapViewPrefs.shared.darkColor
        centerLocationButton.layer.cornerRadius = 22.0
        centerLocationButton.setImage(.init(systemName: "location"), for: .normal)
        centerLocationButton.contentHorizontalAlignment = .fill
        centerLocationButton.contentVerticalAlignment = .fill
        centerLocationButton.imageView?.contentMode = .scaleAspectFit
        centerLocationButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        centerLocationButton.tintColor = ForecastsMapViewPrefs.shared.lightColor
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
        currentAllergenButton.backgroundColor = ForecastsMapViewPrefs.shared.darkColor
        currentAllergenButton.setTitleColor(ForecastsMapViewPrefs.shared.lightColor, for: .normal)
        currentAllergenButton.setTitleColor(ForecastsMapViewPrefs.shared.semiDarkColor, for: .highlighted)
        currentAllergenButton.layer.cornerRadius = 8.0
        view.addSubview(currentAllergenButton)
        currentAllergenButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(8)
            make.width.equalTo(66).priority(.medium)
            make.height.equalTo(36)
        }
        currentAllergenButton.addTarget(self, action: #selector(handleForecastButtons), for: .touchUpInside)

        view.addSubview(playerControls.view)
        addChild(playerControls)
        playerControls.view.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
        playerControls.delegate = self
        
        view.addSubview(currentIntervalLabel)
        currentIntervalLabel.snp.makeConstraints { make in
            make.centerX.equalTo(playerControls.view)
            make.top.equalTo(currentAllergenButton)
            make.bottom.equalTo(currentAllergenButton)
            make.height.equalTo(36)
            make.width.equalTo(16).priority(.medium)
        }
        currentIntervalLabel.textColor = ForecastsMapViewPrefs.shared.lightColor
        currentIntervalLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        currentIntervalLabel.backgroundColor = ForecastsMapViewPrefs.shared.darkColor
        currentIntervalLabel.textColor = ForecastsMapViewPrefs.shared.lightColor
        currentIntervalLabel.textAlignment = .center
        currentIntervalLabel.text = "none"
        currentIntervalLabel.clipsToBounds = true
        currentIntervalLabel.layer.cornerRadius = 8.0
        currentIntervalLabel.leftInset = 8.0
        currentIntervalLabel.rightInset = 8.0
    }
    
    func addLoadingForecastConrols() {
        guard let reloadButton = loadingForecastControls[.reloadButton] as? UIButton else { return }
        reloadButton.setTitle("Загрузить", for: .normal)
        reloadButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        reloadButton.backgroundColor = ForecastsMapViewPrefs.shared.darkColor
        reloadButton.layer.cornerRadius = 8.0
        reloadButton.setTitleColor(ForecastsMapViewPrefs.shared.lightColor, for: .normal)
        reloadButton.setTitleColor(ForecastsMapViewPrefs.shared.semiDarkColor, for: .highlighted)

        view.addSubview(reloadButton)
        reloadButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(8)
            make.width.equalTo(88).priority(.medium)
            make.height.equalTo(36)
        }
        reloadButton.addTarget(self, action: #selector(handleLoadingButtons), for: .touchUpInside)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.snp.makeConstraints { make in
            make.right.equalTo(reloadButton.snp.right)
            make.height.equalTo(reloadButton.snp.height)
            make.top.equalTo(reloadButton.snp.bottom).offset(4)
        }
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.stopAnimating()
        loadingSpinner.tintColor = ForecastsMapViewPrefs.shared.semiDarkColor

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

extension ForecastsMapViewController: ForecastsPlayerViewControllerDelegate {
    func next() {
        model.currentIntervalIndex += 1
        reloadData()
    }
    
    func prev() {
        model.currentIntervalIndex -= 1
        reloadData()
    }
    
    func pause() {
        timer.invalidate()
    }
    
    func play() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.model.currentIntervalIndex += 1
            if (self.model.currentIntervalIndex >= self.model.intervalsList.count-1) {
                self.model.currentIntervalIndex = 0
            }
            self.reloadData()
        }
    }
}
