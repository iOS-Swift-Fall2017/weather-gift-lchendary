//
//  DetailVC.swift
//  WeatherGift
//
//  Created by Linda Chen on 10/17/17.
//  Copyright © 2017 Synestha. All rights reserved.
//

import UIKit
import CoreLocation

class DetailVC: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var currentPage = 0
    var locationsArray = [WeatherLocation]()
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        locationLabel.text = locationsArray[currentPage].name
        dateLabel.text = locationsArray[currentPage].coordinates
        if currentPage != 0 {
            self.locationsArray[currentPage].getWeather {
                self.updateUserInterface()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentPage == 0 {
            getLocation()
        }
    }
    
    func updateUserInterface() {
        
        let location = locationsArray[currentPage]
        locationLabel.text = location.name
        
        let dateString = formatTimeForTimeZone(unixDate: location.currentTime, timeZone: location.timeZone)
        
        dateLabel.text = dateString
        
        temperatureLabel.text = location.currentTemp + "°"
        summaryLabel.text = location.currentSummary
        currentImage.image = UIImage(named: location.currentIcon)
        
        //If you don't do this there wont be any data.
        tableView.reloadData()
    }
    
    func formatTimeForTimeZone(unixDate: TimeInterval, timeZone: String) -> String {
        // Convert the Unix date to a usable iOS Date type
        let usableDate = Date(timeIntervalSince1970: unixDate)
        
        // Create a DateFormatter object called dateFormatter
        let dateFormatter = DateFormatter()
        
        // Set the .dateFormat property of the DateFormatter object
        // to convert Weekday (EEEE), Month abbreviation (MMM) day (dd), year (y)
        dateFormatter.dateFormat = "EEEE, MMM dd, y"
        
        // Set the .timeZone property of hte DateFormatter object
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        
        // Convert the iOS Date, usableDate, to a .dateFormatted string in .timeZone.
        let dateString = dateFormatter.string(from: usableDate)
        
        // Return the formatted String
        return dateString
    }
    
}

//Location Manager Extension
extension DetailVC: CLLocationManagerDelegate {
    
    func getLocation() {
        let status = CLLocationManager.authorizationStatus()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        handleLocationAuthorizationStatus(status: status)
    }
    
    // Respond to authorization status
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied:
            if currentPage == 0 && self.view.window != nil {
                showAlert(title: "User has not authorized location services", message: "Go to settings to enable location services in this app.")
            }
        case .restricted:
            showAlert(title: "Location Services Denied", message: "Parental controls might be restricting location use in this app.")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // This function is called if status is changed. If so, handle the
    //  status change
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if currentPage == 0 && self.view.window != nil {
            let geoCoder = CLGeocoder()
            
            currentLocation = locations.last
            
            let currentLat = "\(currentLocation.coordinate.latitude)"
            let currentLong = "\(currentLocation.coordinate.longitude)"
            
            var place = ""
            geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {placemarks, error in
                if placemarks != nil {
                    let placemark = placemarks!.last
                    place = (placemark?.name)!
                } else {
                    print("Error retrieving place. Error code \(error)")
                    place = "Unknown"
                }
                self.locationsArray[0].name = place
                self.locationsArray[0].coordinates = currentLat + "," + currentLong
                self.locationsArray[0].getWeather {
                    self.updateUserInterface()
                }
            })
            
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location. Error code \(error)")
    }
}

extension DetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationsArray[currentPage].dailyForecastArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayWeatherCell") as! DayWeatherCell
        let dailyForecast = locationsArray[currentPage].dailyForecastArray[indexPath.row]
        cell.update(with: dailyForecast)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}


