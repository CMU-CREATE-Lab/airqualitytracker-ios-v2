//
//  AddTaskViewController.swift
//  V3
//
//  Created by Mohak Nahta  on 6/9/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//


//bug for pittsburgh -> pittsburgh locksmith (nil value) 
import UIKit

var searcher : UISearchController!


class AddTaskViewController: UIViewController, UISearchBarDelegate {
    

    
    @IBOutlet weak var searchBarView: UIView!
    
    let googleAPI = GoogleAPI()
    let src = AutoCompleteController()
    
    var descriptionLabel: String! = ""
    var AQILabel: String!
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var currentTemperature: String  = ""
    var currentTime: String = ""
    var currentOzone: String = ""
    var stationID: Int = 0
    var airQuality: Int = 0
    
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
            
            googleAPI.fetchPlacesDetail(src.placeIdArray[positionInArray]){ place in
                
                self.latitude = place!.coordinate.latitude as Double
                self.longitude = place!.coordinate.longitude as Double
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.getCurrentAirQuality()
                    self.getCurrentWeatherData()
                    })
                
                //MN: calling the segue here as the user is done with search
                self.performSegueWithIdentifier("dismissAndSave", sender: self)
            }
        }
    }
    
    func getCurrentAirQuality() -> Void {
        
        var currentLatitude = latitude
        var currentLongitude = longitude
        
        var currentDate = NSDate()
        var currentDateInSeconds = currentDate.timeIntervalSince1970
        var last24Hours = Int(currentDateInSeconds - (60 * 60 * 24))
        
        var (latMin, latMax, lonMin, lonMax) = createBoundingBox(currentLatitude, currentLongitude: currentLongitude)
        
        
        let airQualityURL = NSURL(string: "https://esdr.cmucreatelab.org/api/v1/feeds?whereAnd=productId=11,latitude%3E=\(latMin),latitude%3C=\(latMax),longitude%3E=\(lonMin),longitude%3C=\(lonMax),maxTimeSecs%3E=\(last24Hours)&fields=id,name,latitude,longitude,channelBounds")
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(airQualityURL!, completionHandler: { (data: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            let dataObject = NSData(contentsOfURL: data)
            let airQualityDictionary: NSDictionary =
            NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as! NSDictionary //casting
            
            let currentAir = CurrentAirQuality(airQualityDictionary: airQualityDictionary, currentLatitude: currentLatitude, currentLongitude: currentLongitude, last24Hours: last24Hours)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.stationID = currentAir.closestStationID
                self.getAQI()
            })
            
        })
        downloadTask.resume()
        
    }
    
    func getAQI() -> Void {
        var placesTask = NSURLSessionDataTask()
        var session: NSURLSession {
            return NSURLSession.sharedSession()
        }
        println("entering AQI most recent value methods and call...")
        println("station ID is \(self.stationID)")
        var AQIURL = "https://esdr.cmucreatelab.org/api/v1/feeds/\(self.stationID)/most-recent"
        
        var AQIURLString = AQIURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
            placesTask.cancel()
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        placesTask = session.dataTaskWithURL(NSURL(string: AQIURLString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if let dataObject = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary{
                
                if let data = dataObject["data"] as? NSDictionary {
                    println("first if conditional passed...")
                    if let channels = data["channels"] as? NSDictionary {
                        println("second if conditional passed...")
                        if let val: AnyObject = channels["PM2_5"]{
                            println("in PM2.5...")
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
                    }
                    
                }
            }
        }
        placesTask.resume()
    }
    
    func getMostRecentValue(channelsDict: NSDictionary, identifier: String){
        println("in getMostRecentValue()...")
        let temp: NSDictionary = channelsDict[identifier] as! NSDictionary
        let mRDS = temp["mostRecentDataSample"] as! NSDictionary
        let airQuality  = mRDS["value"] as! Int
        self.AQILabel = "\(airQuality)"
        println("air quality is \(self.airQuality)")
    }

    func createBoundingBox(currentLatitude: Double, currentLongitude: Double) -> (Double, Double, Double, Double){
        var distance = 10 //in kilometers
        var radius = 6371 //in km
        var angularRadius: Double = Double(distance * 100) / Double(radius) //check this
        var latMin = currentLatitude - angularRadius
        var latMax = currentLatitude + angularRadius
        
        var latT = asin(sin(currentLatitude)/cos(angularRadius))
        var deltaLon = acos( (cos(angularRadius) - (sin(latT) * sin(currentLatitude))) / (cos(latT) * cos(currentLatitude)))
        var lonMin = currentLongitude - deltaLon
        var lonMax = currentLongitude + deltaLon
        
        return (latMin, latMax, lonMin, lonMax)
        
    }

    //MARK: - gets the current weather data based on the coordinates
    func getCurrentWeatherData() -> Void {
        
        var currentLatitude =  latitude
        var currentLongitude = longitude
        
        let apiKey = "87224a504c9c40fe40c2166ff8fb846c"
        
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "\(currentLatitude),\(currentLongitude)", relativeToURL: baseURL)
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if (error == nil) {
                let dataObject = NSData(contentsOfURL: location)
                let weatherDictionary: NSDictionary =
                NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as! NSDictionary //casting
                
                let currentWeather = CurrentWeather(weatherDictionary: weatherDictionary)
                
                var temperatureSymbol: String
                if (SettingsViewController.variables.unit == true){
                    temperatureSymbol = "\u{00B0} F" //symbol for degree F
                }
                    
                else{
                    temperatureSymbol = "\u{00B0} C" //symbol for degree C
                }
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.currentTemperature = "\(currentWeather.temperature)" + "\(temperatureSymbol)"
                    self.currentOzone = "\(currentWeather.ozone)"
                    
                    let location = LocationForList(description: self.descriptionLabel, AQI: self.AQILabel, lat: self.latitude, long: self.longitude, temp: self.currentTemperature, Oz: self.currentOzone)
                    LocationStore.sharedInstance.add(location)
                })
                
            }
                
            else {
                let issue = UIAlertController(title: "Error", message: "Error in connection", preferredStyle: .Alert)
                
                let okIssue = UIAlertAction(title: "OK", style: .Default, handler: nil)
                issue.addAction(okIssue)
                
                let cancelIssue = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                issue.addAction(cancelIssue)
                
                self.presentViewController(issue, animated: true, completion: nil)
                
            }
            
        })
        
        
        
        downloadTask.resume()
    }

    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        performSegueWithIdentifier("dismissAndCancel", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    }

}