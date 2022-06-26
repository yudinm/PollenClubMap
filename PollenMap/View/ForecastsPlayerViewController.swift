//
//  ForecastsPlayerViewController.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 01.06.2022.
//

import Foundation
import UIKit

/**
    – timeline (collection view)
        – display available frames
        – display loaded frames
        – go to frame (datetime)
    – controls
        – next frame
        – prev frame
        – play
        – pause
 */

protocol ForecastsPlayerViewControllerDelegate {
    func next()
    func prev()
    func pause()
    func play()
}

class ForecastsPlayerViewController: UIViewController {
    enum PlayerButtons: Int {
        case next
        case prev
        case play
        case pause
    }
    
    lazy var playerButtons: [PlayerButtons: UIView] = [
        .next: UIButton(),
        .pause: UIButton(),
        .play: UIButton(),
        .prev: UIButton()
    ]
    
    lazy var container = UIView()
    var delegate: ForecastsPlayerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addControls()
    }
}

extension ForecastsPlayerViewController {
    func addControls() {
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addButtons()
    }
    
    func addButtons() {
        let size = CGSize(width: 40, height: 40)
        guard let button1 = playerButtons[.prev] as? UIButton else { return }
        container.addSubview(button1)
        button1.snp.makeConstraints { make in
            make.width.equalTo(size.width)
            make.height.equalTo(size.height)
            make.leading.equalToSuperview().offset(4)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
        }
        button1.tag = PlayerButtons.prev.rawValue
        button1.setImage(.init(systemName: "backward.circle"), for: .normal)
        button1.contentHorizontalAlignment = .fill
        button1.contentVerticalAlignment = .fill
        button1.imageView?.contentMode = .scaleAspectFit
        button1.tintColor = ForecastsMapViewPrefs.shared.lightColor
        button1.layer.shadowColor = ForecastsMapViewPrefs.shared.darkColor.cgColor
        button1.layer.shadowOffset = .init(width: 1, height: 1)
        button1.layer.shadowOpacity = 1.0
        button1.layer.shadowRadius = 2
        button1.addTarget(self, action: #selector(handleControlsButton), for: .touchUpInside)
        guard let button2 = playerButtons[.pause] as? UIButton else { return }
        container.addSubview(button2)
        button2.snp.makeConstraints { make in
            make.width.equalTo(size.width)
            make.height.equalTo(size.height)
            make.leading.equalTo(button1.snp.trailing).offset(4)
            make.centerY.equalTo(button1)
        }
        button2.tag = PlayerButtons.pause.rawValue
        button2.setImage(.init(systemName: "pause.circle"), for: .normal)
        button2.contentHorizontalAlignment = .fill
        button2.contentVerticalAlignment = .fill
        button2.imageView?.contentMode = .scaleAspectFit
        button2.tintColor = ForecastsMapViewPrefs.shared.lightColor
        button2.layer.shadowColor = ForecastsMapViewPrefs.shared.darkColor.cgColor
        button2.layer.shadowOffset = .init(width: 1, height: 1)
        button2.layer.shadowOpacity = 1.0
        button2.layer.shadowRadius = 2
        button2.addTarget(self, action: #selector(handleControlsButton), for: .touchUpInside)
        guard let button3 = playerButtons[.play] as? UIButton else { return }
        container.addSubview(button3)
        button3.snp.makeConstraints { make in
            make.width.equalTo(size.width)
            make.height.equalTo(size.height)
            make.leading.equalTo(button2.snp.trailing).offset(4)
            make.centerY.equalTo(button2)
        }
        button3.tag = PlayerButtons.play.rawValue
        button3.setImage(.init(systemName: "play.circle"), for: .normal)
        button3.contentHorizontalAlignment = .fill
        button3.contentVerticalAlignment = .fill
        button3.imageView?.contentMode = .scaleAspectFit
        button3.tintColor = ForecastsMapViewPrefs.shared.lightColor
        button3.layer.shadowColor = ForecastsMapViewPrefs.shared.darkColor.cgColor
        button3.layer.shadowOffset = .init(width: 1, height: 1)
        button3.layer.shadowOpacity = 1.0
        button3.layer.shadowRadius = 2
        button3.addTarget(self, action: #selector(handleControlsButton), for: .touchUpInside)
        guard let button4 = playerButtons[.next] as? UIButton else { return }
        container.addSubview(button4)
        button4.snp.makeConstraints { make in
            make.width.equalTo(size.width)
            make.height.equalTo(size.height)
            make.leading.equalTo(button3.snp.trailing).offset(4)
            make.centerY.equalTo(button3)
            make.trailing.equalToSuperview()
        }
        button4.tag = PlayerButtons.next.rawValue
        button4.setImage(.init(systemName: "forward.circle"), for: .normal)
        button4.contentHorizontalAlignment = .fill
        button4.contentVerticalAlignment = .fill
        button4.imageView?.contentMode = .scaleAspectFit
        button4.tintColor = ForecastsMapViewPrefs.shared.lightColor
        button4.layer.shadowColor = ForecastsMapViewPrefs.shared.darkColor.cgColor
        button4.layer.shadowOffset = .init(width: 1, height: 1)
        button4.layer.shadowOpacity = 1.0
        button4.layer.shadowRadius = 2
        button4.addTarget(self, action: #selector(handleControlsButton), for: .touchUpInside)
    }
}


extension ForecastsPlayerViewController {
    @objc func handleControlsButton(sender: UIButton) {
        switch PlayerButtons(rawValue: sender.tag) {
        case .prev:
            delegate?.prev()
        case .next:
            delegate?.next()
        case .play:
            delegate?.play()
        case .pause:
            delegate?.pause()
        case .none:
            break
        }
    }
}
