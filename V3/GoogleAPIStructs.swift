// GoogleAPIStructs.swift
// Created by Mohak Nahta with hints and prtial code from https://github.com/wiserkuo/Swift-SearchController

import UIKit
import Foundation
import CoreLocation

//this class stores the description of the location and the place id, which is then sent as another api call to retrieve more information in Detail such as longitdue and latitude
class NameAndID {
    let description : String
    let place_id : String
//    let coordinate:CLLocationCoordinate2D
    let coordinateForList: String
    
    init(dictionary:NSDictionary){
//        description = dictionary["description"] as! String
//        place_id = dictionary["place_id"] as! String
        description = dictionary["name"] as! String
        place_id = dictionary["l"] as! String
        let lat = dictionary["lat"] as! String
        let lng = dictionary["lon"] as! String
//        coordinate = CLLocationCoordinate2DMake(lat, lng)
        coordinateForList = "\(lat), \(lng)"
//        coordinateForList = "\(String(stringInterpolationSegment: lat))" + "," + "\(String(stringInterpolationSegment: lng))"
        println("coordinates for list \(coordinateForList)")
    }
}

class Detail {
    let address :String
    let coordinate:CLLocationCoordinate2D
    let coordinateForList: String
    
//    init(dictionary:NSDictionary){
    init(){
        address  = "5000 Forbes" //dictionary["formatted_address"] as! String
//        let location = dictionary["geometry"]?["location"] as! NSDictionary
        let lat = 40.4 //location["lat"] as! CLLocationDegrees
        let lng = -79.1 //location["lng"] as! CLLocationDegrees
        coordinate = CLLocationCoordinate2DMake(lat, lng)
        coordinateForList = "\(String(stringInterpolationSegment: lat))" + "," + "\(String(stringInterpolationSegment: lng))"
    }
}
