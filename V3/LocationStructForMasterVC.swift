//
//  LocationForList.swift
//  V3
//
//  Created by Mohak Nahta  on 6/9/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

struct LocationForList {
    
    var description: String
    var AQI: String
    var lat: Double
    var long: Double
    var temp: String
    var Oz: String
    var aqiCategory: String
    var pmValue: Double
    
    init(description: String, AQI: String, lat: Double, long: Double, temp: String, Oz: String, aqiCategory: String, pmValue: Double) {
        //doing this string arithmetic to ensure that only the first location identifier is displayed 
        //for example: If the user searches for CREATE Lab, Forbes Avenue, Pittsburgh, PA, the app will only dispay CREATE LAB
        
        var identifierSeparator = description.rangeOfString(",")

        if (identifierSeparator == nil){
            self.description = description
        }
        
        else {
            var shortDescription = description.substringWithRange(Range<String.Index>(start: description.startIndex, end: identifierSeparator!.startIndex))
            self.description = shortDescription
        }
        self.AQI = AQI
        self.lat = lat
        self.long = long
        self.temp = temp
        self.Oz = Oz
        self.aqiCategory = aqiCategory
        self.pmValue = pmValue
    }
}