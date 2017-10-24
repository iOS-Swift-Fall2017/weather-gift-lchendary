//
//  WeatherLocation.swift
//  WeatherGift
//
//  Created by Linda Chen on 10/24/17.
//  Copyright © 2017 Synestha. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeatherLocation {
    var name = ""
    var coordinates = ""
    
    func getWeather() {
        let weatherURL = urlBase + urlAPIKey + coordinates
        print(weatherURL)
        
        Alamofire.request(weatherURL).responseJSON { response in
            print(response)
        }
    }
    

}
