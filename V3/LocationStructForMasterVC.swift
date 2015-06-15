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
    var coordinate: String
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var airQualityStationID: Int = 0
    
    
    init(description: String, coordinate: String) {
        
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
         self.coordinate = coordinate
//        var coordinateS = coordinate
//        var coordinateSeperator = coordinateS.rangeOfString(",")
//        var coordinateSeparatorindex: Int = distance(coordinateS.startIndex, coordinateSeperator!.startIndex)
//        
//        var latitudeS = coordinateS.substringWithRange(Range<String.Index>(start: coordinateS.startIndex, end: coordinateSeperator!.startIndex))
//        
//        var longitudeS = coordinateS.substringWithRange(Range<String.Index>(start: advance(coordinateS.startIndex, coordinateSeparatorindex + 1), end: advance(coordinateS.endIndex, -1)))
//        
//        latitude = NSString(string: latitudeS).doubleValue
//        longitude = NSString(string: longitudeS).doubleValue
//        
//        self.coordinate = coordinate
//        
//        var currentLatitude = latitude
//        var currentLongitude = longitude
//        
//        var currentDate = NSDate()
//        var currentDateInSeconds = currentDate.timeIntervalSince1970
//        var last24Hours = currentDateInSeconds - (60 * 60 * 24)
//        
//        var (latMin, latMax, lonMin, lonMax) = createBoundingBox(currentLatitude, currentLongitude: currentLongitude)
//        
//        
//        let airQualityURL = NSURL(string: "https://esdr.cmucreatelab.org/api/v1/feeds?whereAnd=productId=11,latitude%3E=\(latMin),latitude%3C=\(latMax),longitude%3E=\(lonMin),longitude%3C=\(lonMax),maxTimeSecs%3E=\(last24Hours)&fields=id,name,latitude,longitude,channelBounds")
//        
//        let sharedSession = NSURLSession.sharedSession()
//        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(airQualityURL!, completionHandler: { (data: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
//            
//            
//            let dataObject = NSData(contentsOfURL: data)
//            let airQualityDictionary: NSDictionary =
//            NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as! NSDictionary //casting
//            
//            let currentAir = CurrentAirQuality(airQualityDictionary: airQualityDictionary, currentLatitude: currentLatitude, currentLongitude: currentLongitude)
//            
//            self.airQualityStationID = currentAir.closestStationID
//            self.coordinate = "\(currentAir.closestStationID)"
//
//        })
}

//    func createBoundingBox(currentLatitude: Double, currentLongitude: Double) -> (Double, Double, Double, Double){
//        var distance = 10 //in kilometers
//        var radius = 6371 //in km
//        var angularRadius: Double = Double(distance * 100) / Double(radius) //check this
//        var latMin = currentLatitude - angularRadius
//        var latMax = currentLatitude + angularRadius
//        
//        var latT = asin(sin(currentLatitude)/cos(angularRadius))
//        var deltaLon = acos( (cos(angularRadius) - (sin(latT) * sin(currentLatitude))) / (cos(latT) * cos(currentLatitude)))
//        var lonMin = currentLongitude - deltaLon
//        var lonMax = currentLongitude + deltaLon
//        
//        return (latMin, latMax, lonMin, lonMax)
//        
//    }

}



