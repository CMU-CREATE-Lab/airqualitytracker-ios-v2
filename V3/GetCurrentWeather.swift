//
//  GetCurrentWeather.swift
//  V3
//
//  Created by Mohak Nahta  on 6/11/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import Foundation
import UIKit

struct Current {
    
    var temperature: Int = 0
    var summary: String
    var ozone: Int
    
    init(weatherDictionary: NSDictionary) {
        var currentWeather = weatherDictionary["currently"] as! NSDictionary
        summary = currentWeather["summary"] as! String
        ozone = currentWeather["ozone"] as! Int
        var tempTemperature = currentWeather["temperature"] as! Int
        if (SettingsViewController.variables.unit == false){
            temperature = convertToCelcius(tempTemperature)
        }
        else{
            temperature = tempTemperature
        }

    }
    
    func convertToCelcius(farhenheit: Int) -> Int {
        var celcius: Double = (Double(farhenheit) - 32.0) * (5/9)
        return Int(celcius)
    }
}
