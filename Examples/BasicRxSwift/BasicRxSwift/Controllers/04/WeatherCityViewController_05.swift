//
//  WeatherCityViewController.swift
//  
//
//  Created by Le Phuong Tien on 9/2/20.
//

import UIKit
import RxCocoa
import RxSwift
import CoreLocation
import MapKit

class WeatherCityViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private var searchCityName: UITextField!
    @IBOutlet private var tempLabel: UILabel!
    @IBOutlet private var humidityLabel: UILabel!
    @IBOutlet private var iconLabel: UILabel!
    @IBOutlet private var cityNameLabel: UILabel!
    @IBOutlet weak var containerView: UIStackView!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var mapButton: UIButton!
    
    // MARK: - Properties
    let bag = DisposeBag()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        
        // MARK: - INPUT
        let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchCityName.text ?? "" }
            .filter { !$0.isEmpty }
        
        // MARK: - SEARCH
        let search = searchInput
            .flatMapLatest { text  in
                return WeatherAPI.shared.currentWeather(city: text)
                    .catchErrorJustReturn(Weather.empty)
            }
            .asDriver(onErrorJustReturn: Weather.empty)
        
        // MARK: - DRIVE
        search.map { "\($0.temperature) °C" }
            .drive(tempLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(cityNameLabel.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity) %" }
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.icon }
            .drive(iconLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(self.rx.title)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(self.rx.title)
            .disposed(by: bag)
        
        // MARK: LOADING
        let loading = Observable.merge(
                        searchInput.map { _ in true },
                        search.map { _ in false }.asObservable()
                    )
                    .startWith(true)
                    .asDriver(onErrorJustReturn: false)
        
        loading
            .skip(1)
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)

        loading
            .drive(containerView.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(tempLabel.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(iconLabel.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(humidityLabel.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .drive(cityNameLabel.rx.isHidden)
            .disposed(by: bag)


    }
    
    // MARK: - private methods
    private func configUI() {
        title = "Weather City"
    }

}


// MARK: - Custom Binder
extension Reactive where Base: WeatherCityViewController {
    var title: Binder<String> {
        return Binder(self.base) { (vc, value) in
            vc.title = value
        }
    }
}
