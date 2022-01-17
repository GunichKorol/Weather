//
//  ViewController.swift
//  Weather
//
//  Created by Kirill Gunich-Korol on 4.01.22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelTemp: UILabel!
    @IBOutlet weak var imageWeather: UIImageView!
    
    
    
    let locationManager = CLLocationManager()//получение координат
    var weatherData = WeatherData()
    override func viewDidLoad() {
        super.viewDidLoad()
        startLocationManager()
    }

    func startLocationManager() {
        //запрос на авторизацию(запрос у пользователя)
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled()//вкл ли геолокация
        {
            locationManager.delegate = self //если меняется местоположение, то срабатывает делегат
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //точность получения координат
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation() //запуск слежения местоположения
        }
    }
    
    func updateView () {
        labelCity.text = weatherData.name
        labelDescription.text = DataSource.weatherIDs[weatherData.weather[0].id]
        labelTemp.text = weatherData.main.temp.description + "°"
        imageWeather.image = UIImage(named: weatherData.weather[0].icon)
    }
    
    //обновляет инфу о погоде
    func updateWeather(latitude: Double, longtitude: Double) {
        let session = URLSession.shared
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longtitude.description)&units=metric&lang=ru&APPID=9b7065afbc002b050a29d80f0b15b8f6")!
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("DataTask error: \(error!.localizedDescription)")
                return
            }
            do {
                self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                DispatchQueue.main.async {
                    self.updateView()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
}
//получение местоположение
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            updateWeather(latitude: lastLocation.coordinate.latitude, longtitude: lastLocation.coordinate.longitude)
        }
    }
    
}
