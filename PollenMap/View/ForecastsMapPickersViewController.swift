//
//  ForecastsMapPickers.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 27.05.2022.
//

import UIKit
import SnapKit
import CoreLocation

class ForecastsMapPickersViewController: UIViewController {
    
    enum ForecastPickers {
        case currentAllergenPicker
        case currentIntervalPicker
        case loadIntervalNumberPicker
    }
    
    enum ForecastPickersToolbar: Int {
        case cancelButton
        case doneButton
    }
    
    lazy var forecastPickers: [ForecastPickers: UIView] = [
        .currentAllergenPicker: UIPickerView(),
        .currentIntervalPicker: UIPickerView(),
        .loadIntervalNumberPicker: UIPickerView()
    ]
    
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barTintColor = ForecastsMapViewPrefs.shared.darkColor
        toolbar.setItems([
            {
                let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(toolbarButtonHandler))
                button.tag = ForecastPickersToolbar.cancelButton.rawValue
                button.tintColor = ForecastsMapViewPrefs.shared.lightColor
                return button
            }(),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            {
                let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolbarButtonHandler))
                button.tag = ForecastPickersToolbar.doneButton.rawValue
                button.tintColor = ForecastsMapViewPrefs.shared.lightColor
                return button
            }()
        ], animated: false)
                          
        return toolbar
    }()
    
    var model: ForecastModel! {
        didSet {
            pickerInterval = model.currentInterval
            pickerAllergen = model.currentAllergen
        }
    }
    var currentPickerType: ForecastPickers!
    var completion: (() -> Void)?
    var pickerAllergen: Allergen!
    var pickerInterval: Interval!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addControls()
        view.backgroundColor = ForecastsMapViewPrefs.shared.darkColor
    }
}

extension ForecastsMapPickersViewController {
    func addControls() {
        addToolbar()
        addPickerView()
    }
    
    func addToolbar() {
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(44.0)
            make.top.equalToSuperview()
        }
    }
    
    func addPickerView() {
        guard let picker = forecastPickers[currentPickerType] as? UIPickerView else {return}
        picker.dataSource = self
        picker.delegate = self
        picker.backgroundColor = ForecastsMapViewPrefs.shared.darkColor
        view.addSubview(picker)
        picker.snp.makeConstraints { make in
            make.top.equalTo(toolbar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }
        picker.selectRow(rowFor(pickerType: currentPickerType, and: model.currentAllergen), inComponent: 0, animated: false)
    }
}

extension ForecastsMapPickersViewController {
    @objc func toolbarButtonHandler(_ sender: UIBarButtonItem) {
        switch ForecastPickersToolbar(rawValue: sender.tag) {
        case .doneButton:
            dismiss(animated: true) {
                guard let completion = self.completion else { return }
                switch self.currentPickerType {
                case .currentAllergenPicker:
                    self.model.currentAllergen = self.pickerAllergen
                    completion()
                case .currentIntervalPicker:
                    self.model.currentInterval = self.pickerInterval
                    completion()
                case .none:
                    break
                case .some(.loadIntervalNumberPicker):
                    break
                }
            }
        case .cancelButton:
            dismiss(animated: true)
        case .none:
            break
        }

    }
}

extension ForecastsMapPickersViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch currentPickerType {
        case .currentAllergenPicker:
            return model.allergens.count
        case .currentIntervalPicker:
            return model.intervalsList.count
        case .loadIntervalNumberPicker:
            return 14 // ???
        case .none:
            return 0
        }
    }
}

extension ForecastsMapPickersViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch currentPickerType {
        case .currentAllergenPicker:
            return (dataFor(pickerType: currentPickerType, and: row) as! Allergen)
        case .currentIntervalPicker:
            return "\(dataFor(pickerType: currentPickerType, and: row) as! Interval)"
        case .loadIntervalNumberPicker:
            return "14" // ???
        case .none:
            return "0"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch currentPickerType {
        case .currentAllergenPicker:
            pickerAllergen = (dataFor(pickerType: currentPickerType, and: row) as! Allergen)
        case .currentIntervalPicker:
            pickerInterval = (dataFor(pickerType: currentPickerType, and: row) as! Interval)
        case .loadIntervalNumberPicker:
            break
        case .none:
            break
        }
    }
}

extension ForecastsMapPickersViewController {
    func rowFor(pickerType: ForecastPickers, and data: Any) -> Int {
        switch currentPickerType {
        case .currentAllergenPicker:
            return model.allergens.firstIndex(of: data as! Allergen) ?? 0
        case .currentIntervalPicker:
            return model.intervalsList.firstIndex(of: data as! Interval) ?? 0
        case .loadIntervalNumberPicker:
            return 0
        case .none:
            return 0
        }
    }
    
    func dataFor(pickerType: ForecastPickers, and row: Int) -> Any {
        switch pickerType {
        case .currentAllergenPicker:
            return model.allergens[row]
        case .currentIntervalPicker:
            return model.intervalsList[row]
        case .loadIntervalNumberPicker:
            return 0
        }
    }
}
