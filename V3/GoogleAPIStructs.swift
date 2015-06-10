// GoogleAPIHelper.swift
// SearchForSpeck

// Created by Mohak Nahta with hints and prtial code from https://github.com/wiserkuo/Swift-SearchController

import UIKit
import Foundation
import CoreLocation

//this class stores the description of the location and the place id, which is then sent as another api call to retrieve more information in Detail such as longitdue and latitude
class NameAndID {
    let description : String
    let place_id : String
    
    init(dictionary:NSDictionary){
        description = dictionary["description"] as! String
        place_id = dictionary["place_id"] as! String
    }
    
}
class Detail {
    let address :String
    let coordinate:CLLocationCoordinate2D
    let coordinateForList: String
    
    init(dictionary:NSDictionary){
        
        address  = dictionary["formatted_address"] as! String
        let location = dictionary["geometry"]?["location"] as! NSDictionary
        let lat = location["lat"] as! CLLocationDegrees
        let lng = location["lng"] as! CLLocationDegrees
        coordinate = CLLocationCoordinate2DMake(lat, lng)
        coordinateForList = "\(String(stringInterpolationSegment: lat))" + "," + "\(String(stringInterpolationSegment: lng))"
        
        println("Detail: address \(address), coordinateForList \(coordinateForList)") //extract the zip code here if needed
    }
}