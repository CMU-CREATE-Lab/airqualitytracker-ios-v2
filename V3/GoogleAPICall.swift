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
    
    func fetchPlacesAutoComplete(input:String, finished: (([NameAndID]) -> Void)) -> ()
    {
        namesAndIDs.removeAll()
        
        var urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=\(apiKey)&input=\(input)&components=country:US"
        //https://developers.google.com/maps/documentation/geocoding/#ComponentFiltering
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
            placesTask.cancel()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.namesAndIDs = [NameAndID]()
            if let dataObject = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary{
                if let results = dataObject["predictions"] as? NSArray{
                    for rawPlace:AnyObject in results{
                        let place = NameAndID(dictionary: rawPlace as! NSDictionary)
                        self.namesAndIDs.append(place)
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                finished(self.namesAndIDs)
            }
        }
        placesTask.resume()
    }
    func fetchPlacesDetail(placeid:String, finished: ((Detail?) -> Void)) -> ()
    {
        var place : Detail!
        var urlString = "https://maps.googleapis.com/maps/api/place/details/json?key=\(apiKey)&placeid=\(placeid)"
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
            placesTask.cancel()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
                if let results = json["result"] as? NSDictionary {
                    place = Detail(dictionary: results)                    
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                finished(place)
            }
        }
        placesTask.resume()
    }
}