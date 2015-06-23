//
//  GetCurrentWeather.swift
//  V3
//
//  Created by Mohak Nahta  on 6/11/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import Foundation
import UIKit

struct CurrentWeather {
    
    var temperature: Int = 0
    var ozone: Int
    
    init(weatherDictionary: NSDictionary) {
        
        if let val: NSDictionary = weatherDictionary["currently"] as? NSDictionary{
            var currentWeather = val
            if let val1: Int = currentWeather["ozone"] as? Int{
                ozone = val1
            }
            else{
                ozone = 0
            }
            var tempTemperature: Int = 0
            if let val2: Int = currentWeather["temperature"] as? Int{
                 tempTemperature = val2
            }
            else{
                 tempTemperature = 500
            }
            
            if (SettingsViewController.variables.unit == false){
                temperature = convertToCelcius(tempTemperature)
            }
            else{
                temperature = tempTemperature
            }
        }
        else{
            //#####################################
            temperature = 500 //MN: if temperaturee cannot be found
            ozone = 0
        }
        
    }
    
    func convertToCelcius(farhenheit: Int) -> Int {
        var celcius: Double = (Double(farhenheit) - 32.0) * (5/9)
        return Int(celcius)
    }
    
   
    
    func dateStringFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.stringFromDate(weatherDate)
    }

}
