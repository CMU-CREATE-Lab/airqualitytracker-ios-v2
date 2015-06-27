//
//  GoogleAPICall.swift
//  SearchForSpeck
//
//  Created by Mohak Nahta with hints and prtial code from https://github.com/wiserkuo/Swift-SearchController

import UIKit
import Foundation
import CoreLocation


class GoogleAPI {
    
    let apiKey = "AIzaSyDko8xDuNGlFFTOfJgLZ3PWHqIe-XmXSLo" //account used: airvizdev@gmail.com
    //autocomplete feature is on to make the search more user-friendly
    var placesTask = NSURLSessionDataTask()
    var session: NSURLSession {
        return NSURLSession.sharedSession()
    }
    var namesAndIDs = [NameAndID]()
    var searchPredictionsArray = [(String, String)]()
    
    func fetchPlacesAutoComplete(input:String, finished: (([NameAndID]) -> Void)) -> ()
    {
        namesAndIDs.removeAll()
        
//        var urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=\(apiKey)&input=\(input)&components=country:US"
        //https://developers.google.com/maps/documentation/geocoding/#ComponentFiltering
        
        var urlString = "http://autocomplete.wunderground.com/aq?query=\(input)"
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
            placesTask.cancel()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.namesAndIDs = [NameAndID]()
            if let dataObject = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary{
//                if let results = dataObject["predictions"] as? NSArray{
                 if let results = dataObject["RESULTS"] as? NSArray{
                    
                    for rawPlace:AnyObject in results{
                        let place = NameAndID(dictionary: rawPlace as! NSDictionary)
                        self.namesAndIDs.append(place)
                        self.searchPredictionsArray.append((place.description, place.coordinateForList))
//                        println("Before it is finished names and ids is \(self.namesAndIDs)")
//                        println("******")
//                        println("place des \(place.description)")
//                        println("plac coordinates for list \(place.coordinateForList)")
//                        println("search \(self.searchPredictionsArray)")
//                        println("*********")

                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                finished(self.namesAndIDs)
            }
        }
        placesTask.resume()
    }
    
    
    //SINCE YOU HAVE THE NAME, PASS ON THE DICTIONARY PASSED TO NAMEANDID, AND THEN SEARCH FOR THAT NAME, AND THEN SEARCH FOR LONGITUDE AND LATITTUDE....
    func fetchPlacesDetail(placeid:String, finished: ((Detail?) -> Void)) -> ()
    {
        var place : Detail!
        println("search \(searchPredictionsArray)")
        place = Detail()
        finished(place)
    }
//        var urlString = "https://maps.googleapis.com/maps/api/place/details/json?key=\(apiKey)&placeid=\(placeid)"
//        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
//        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
//            placesTask.cancel()
//        }
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
//                if let results = json["result"] as? NSDictionary {
//                    place = Detail(dictionary: results)
//                    dispatch_async(dispatch_get_main_queue()) {
//                        finished(place)
//                    }
//                }
//            }
//        }
//        placesTask.resume()
//    }
}