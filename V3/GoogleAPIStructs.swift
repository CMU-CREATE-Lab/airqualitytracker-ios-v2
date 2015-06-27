// GoogleAPIStructs.swift
// Created by Mohak Nahta with hints and prtial code from https://github.com/wiserkuo/Swift-SearchController

import UIKit
import Foundation
import CoreLocation

//this class stores the description of the location and the place id, which is then sent as another api call to retrieve more information in Detail such as longitdue and latitude
class NameAndID {
    let description : String
    let coordinateForList: String
    let latitude: Double
    let longitude: Double
    
    init(dictionary:NSDictionary){
        description = dictionary["name"] as! String
        let latAsString = dictionary["lat"] as! String
        let lngAsString = dictionary["lon"] as! String
        latitude = (latAsString as NSString).doubleValue
        longitude = (lngAsString as NSString).doubleValue
        coordinateForList = "\(latAsString), \(lngAsString)"
    }
}