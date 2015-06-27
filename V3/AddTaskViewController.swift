//
//  AddTaskViewController.swift
//  V3
//
//  Created by Mohak Nahta  on 6/9/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import UIKit
import CoreLocation

var searcher : UISearchController! //the search bar

//daily quota for google api reached 
//when searching for Wynn Las Vegas, the error is in the json serialization(print before get aq)
//change it to if let...
class AddTaskViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBarView: UIView!
    
    let APICall = AutoCompleteAPI()
    let src = AutoCompleteController()
    
    var descriptionLabel: String! = ""
    var AQILabel: String!
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var currentTemperature: String  = ""
    var currentOzone: String = ""
    var stationID: Int = 0
    var aqiCategory: String = ""
    var pmValue: Double = 0.0

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //implelemting search bar
        searcher = UISearchController(searchResultsController: src)
        searcher.searchResultsUpdater = src
        searcher.searchBar.delegate = self
        searchBarView.addSubview(searcher.searchBar)
        searcher.searchBar.sizeToFit()
        searcher.dimsBackgroundDuringPresentation = true
        searcher.searchBar.translucent = true
        searcher.searchBar.barStyle = UIBarStyle.BlackTranslucent
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searcher.active = false
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar){
        if src.selected! {
            var positionInArray = src.selectedIndex.row
            descriptionLabel = src.areaNamesArray[positionInArray]
            (self.latitude, self.longitude) = src.coordinateArray[positionInArray]
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.getCurrentAirQuality()
                    self.getCurrentWeatherData()
                })
                //MARK: - calling the segue here as the user is done with search
                self.performSegueWithIdentifier("dismissAndSave", sender: self)
            if (self.latitude == 0.0 || self.longitude  == 0.0){
                //view controller for the error page; appears if a location, which has not air quality is selected.
                self.performSegueWithIdentifier("dismissToError", sender: self)
            }
        }
    }
    
    
    //MARK: - Segue for Cancel Button
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        performSegueWithIdentifier("dismissAndCancel", sender: self)
    }
    

    
//########################MARK: - functions to get data#######################
    //MARK: - AirQuaility for the user's current location
    
    func getCurrentAirQuality() -> Void {
        
        var currentDate = NSDate()
        var currentDateInSeconds = currentDate.timeIntervalSince1970
        var last24Hours = Int(currentDateInSeconds - (60 * 60 * 24))
        
        //getting the latitude minimum/maximum and longitude minimum/maximum from the virtual bounding box
        var (latMin, latMax, lonMin, lonMax) = createBoundingBox(latitude, currentLongitude: longitude)
        
        var esdrURL = "https://esdr.cmucreatelab.org/api/v1/feeds?whereAnd=productId=11,latitude%3E=\(latMin),latitude%3C=\(latMax),longitude%3E=\(lonMin),longitude%3C=\(lonMax),maxTimeSecs%3E=\(last24Hours)&fields=id,name,latitude,longitude,channelBounds"
        
        let currentAQURL = NSURL(string: esdrURL)
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(currentAQURL!, completionHandler: {(data: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            if let dataObject = NSData(contentsOfURL: currentAQURL!){
                if let airQualityDictionary: NSDictionary =
                    NSJSONSerialization.JSONObjectWithData(dataObject, options: nil, error: nil) as? NSDictionary{
                
                let AQ = CurrentAirQuality(airQualityDictionary: airQualityDictionary, currentLatitude: self.latitude, currentLongitude: self.longitude, last24Hours: last24Hours)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.stationID = AQ.closestStationID
                    //now calling getAQI, which will invoke the getMostRecentValue method using the stationID
                    self.getMostRecentAQ()
                })
            }
        }
        })
        downloadTask.resume()
    }

    
    //MARK: - creates the bounding box based on discussions with Chris Bartley and Mike Tasota and research from online sources
    func createBoundingBox(currentLatitude: Double, currentLongitude: Double) -> (Double, Double, Double, Double){
        var channelDistance = 20 //in kilometers
        var radius = 6371 //radius of earth in km
        var angularRadius: Double = Double(channelDistance * 100) / Double(radius)
        //latitude
        var latMin = currentLatitude - angularRadius
        var latMax = currentLatitude + angularRadius
        //longitude
        var latT = asin(sin(currentLatitude)/cos(angularRadius))
        var deltaLon = acos( (cos(angularRadius) - (sin(latT) * sin(currentLatitude))) / (cos(latT) * cos(currentLatitude)))
        var lonMin = currentLongitude - deltaLon
        var lonMax = currentLongitude + deltaLon
        
        return (latMin, latMax, lonMin, lonMax)
    }
    
    //MARK: - gets the most recent air quality based on the station ID
    func getMostRecentAQ() -> Void {
        
        var dataTask = NSURLSessionDataTask()
        var sharedSession: NSURLSession {
            return NSURLSession.sharedSession()
        }
        
        if (self.stationID == 0){ //if there is no station within the bounding box
            self.AQILabel = "N/A"
            self.aqiCategory = "Not Available"
        }
        
        else{
            var mostRecentURL = ("https://esdr.cmucreatelab.org/api/v1/feeds/\(self.stationID)/most-recent").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            if dataTask.taskIdentifier > 0 && dataTask.state == .Running {
                dataTask.cancel()
            }
            
            dataTask = sharedSession.dataTaskWithURL(NSURL(string: mostRecentURL)!) {data, response, error in
                if let dataObject = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
                    
                    if let data = dataObject["data"] as? NSDictionary {
                        println("mostRecentAQ data done...")
                        if let channels = data["channels"] as? NSDictionary {
                            println("mostRecentAQ channels done...")
                            //now checking which feed the data was taken from
                            if let val: AnyObject = channels["PM2_5"]{
                                self.getMostRecentValue(channels, identifier: "PM2_5")
                            }
                            else if let val: AnyObject = channels["PM25B_UG_M3"]{
                                self.getMostRecentValue(channels, identifier: "PM25B_UG_M3")
                            }
                            else if let val: AnyObject = channels["PM25_FL_PERCENT"]{
                                self.getMostRecentValue(channels, identifier: "PM25_FL_PERCENT")
                            }
                            else if let val: AnyObject = channels["PM25_UG_M3"]{
                                self.getMostRecentValue(channels, identifier: "PM25_UG_M3")
                            }
                            else{
                                self.AQILabel = "N/A"
                                self.aqiCategory = "Not Available"
                            }
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
    /*MARK: - helper function to getMostRecentAQ, this function takes the dictionaries and the feed
    (PM2.5, PM25BUGM3, PM25FLPERCENT or PM25UGM3) and gets the most recent value
    */
    func getMostRecentValue(channelsDict: NSDictionary, identifier: String){
        let temp: NSDictionary = channelsDict[identifier] as! NSDictionary
        let mostRecentDataSample = temp["mostRecentDataSample"] as! NSDictionary
        let aQ  = mostRecentDataSample["value"] as! Double
        self.pmValue = aQ
        let AQIData  = ConvertToAQI(pmValue: aQ)
        self.aqiCategory = AQIData.category
        self.AQILabel = "\(AQIData.AQI)"
    }
    
    //MARK: - gets the current weather data based on the coordinates
    func getCurrentWeatherData() -> Void {
        
        var currentLatitude =  latitude
        var currentLongitude = longitude
        
        let apiKey = "87224a504c9c40fe40c2166ff8fb846c"
        
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "\(currentLatitude),\(currentLongitude)", relativeToURL: baseURL)
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) ->
            Void in
            if (error != nil){
                let issue = UIAlertController(title: "Error", message: "Error in connection", preferredStyle: .Alert)
                let okIssue = UIAlertAction(title: "OK", style: .Default, handler: nil)
                issue.addAction(okIssue)
                let cancelIssue = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                issue.addAction(cancelIssue)
                self.presentViewController(issue, animated: true, completion: nil)
            }
            else {
                let dataObject = NSData(contentsOfURL: location)
                let weatherDictionary: NSDictionary =
                NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as! NSDictionary
                let currentWeather = CurrentWeather(weatherDictionary: weatherDictionary)
                var temperatureSymbol: String
                //based on user defined settings
                if (SettingsViewController.variables.unit){
                    temperatureSymbol = "\u{00B0} F" //symbol for degree F
                }
                else{
                    temperatureSymbol = "\u{00B0} C" //symbol for degree C
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.currentTemperature = "\(currentWeather.temperature)" + "\(temperatureSymbol)"
                    self.currentOzone = "\(currentWeather.ozone)"
                    if (self.AQILabel == nil){
                        self.AQILabel = "N/A"
                        self.aqiCategory = "Not Available"
                    }
                    println("\(self.descriptionLabel)")
                    println("\(self.AQILabel)")
                    println("\(self.latitude), \(self.longitude)")
                    println("\(self.currentTemperature)")
                    println("\(self.currentOzone)")
                    println("\(self.aqiCategory)")
                    
                    
                    let location = LocationForList(description: self.descriptionLabel, AQI: self.AQILabel, lat: self.latitude, long: self.longitude, temp: self.currentTemperature, Oz: self.currentOzone, aqiCategory: self.aqiCategory, pmValue: self.pmValue)
                    LocationStore.sharedInstance.add(location)
                })
            }
        })
        downloadTask.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    }

}