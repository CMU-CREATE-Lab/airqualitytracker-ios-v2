//
//  GoogleAPICall.swift
//  SearchForSpeck
//
//  Created by Mohak Nahta with hints and prtial code from https://github.com/wiserkuo/Swift-SearchController

import UIKit
import Foundation
import CoreLocation


class AutoCompleteAPI {
    
    var placesTask = NSURLSessionDataTask()
    var session: NSURLSession {
        return NSURLSession.sharedSession()
    }
    var namesAndIDs = [NameAndID]()
    
    func fetchPlacesAutoComplete(input:String, finished: (([NameAndID]) -> Void)) -> ()
    {
        namesAndIDs.removeAll()
        
        var urlString = "http://autocomplete.wunderground.com/aq?query=\(input)&c=US"
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
            placesTask.cancel()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.namesAndIDs = [NameAndID]()
            if let dataObject = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary{
                 if let results = dataObject["RESULTS"] as? NSArray{
                    
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
}