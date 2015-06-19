//
//  MasterViewController.swift
//  V3
//
//  Created by Mohak Nahta  on 6/8/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.


import UIKit
import CoreLocation


class MasterViewController: UITableViewController, CLLocationManagerDelegate {
    
    
    var locationManager = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    
    var currentLocation: String = ""
    var stationID: Int = 0
    var airQuality: Int = 0
    
    var currentTemperature: String  = ""
    var currentOzone: String = ""
    var currentTime: String = ""
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        
        //changing the settings button to a settings cog wheel logo
        self.settingsButton.title = NSString(string: "\u{2699}") as String
        if let font = UIFont(name: "Helvetica", size: 24.0) {
            self.settingsButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        
        getCurrentLocality()
        getCurrentWeatherData()
        getCurrentAirQuality()
//        getM()
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    //MARK: - gets current coordinates
    func getCurrentLocality() -> Void {
        
        setupLocation()
        var currentLatitude = latitude
        var currentLongitude = longitude
        
        let reverseGeocodeURL = NSURL(string: "http://api.geonames.org/findNearbyPlaceNameJSON?lat=\(currentLatitude)&lng=\(currentLongitude)&username=airvizdev1")
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(reverseGeocodeURL!, completionHandler: { (data: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            if(error != nil) {
                
                println(error.localizedDescription)
            }

            if (error == nil) {
                let dataObject = NSData(contentsOfURL: data)
                let geoCodeDictionary: NSDictionary =
                NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as! NSDictionary //casting
                
                let currentLocality = CurrentGeocode(geoCodeDictionary: geoCodeDictionary)
                self.currentLocation = "\(currentLocality.name)"

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
    
    func setupLocation(){
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestAlwaysAuthorization()
            
            //MN: ask about distance filter
            locationManager.distanceFilter = 1000
            
            //MN: ask about start and significant change
            locationManager.startUpdatingLocation()
            //locationManager.startMonitoringSignificantLocationChanges()
            if locationManager.location != nil {
                latitude = locationManager.location.coordinate.latitude
                longitude = locationManager.location.coordinate.longitude
            }
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        latitude = locValue.latitude
        longitude = locValue.longitude
    }

    
    //MARK: - AirQuaility For Current Locality
    
    func getCurrentAirQuality() -> Void {
        
        var currentLatitude = latitude
        var currentLongitude = longitude
        
        var currentDate = NSDate()
        var currentDateInSeconds = currentDate.timeIntervalSince1970
        var last24Hours = Int(currentDateInSeconds - (60 * 60 * 24))
        
        println("last 24 hours is \(last24Hours) and \(Int(last24Hours)) and \(Double(last24Hours))")
        var (latMin, latMax, lonMin, lonMax) = createBoundingBox(currentLatitude, currentLongitude: currentLongitude)
        
        var urlString = "https://esdr.cmucreatelab.org/api/v1/feeds?whereAnd=productId=11,latitude%3E=\(latMin),latitude%3C=\(latMax),longitude%3E=\(lonMin),longitude%3C=\(lonMax),maxTimeSecs%3E=\(last24Hours)&fields=id,name,latitude,longitude,channelBounds"
        println("url is \(urlString)")
//        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

        
        let airQualityURL = NSURL(string:urlString  )
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(airQualityURL!, completionHandler: { (data: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            let dataObject = NSData(contentsOfURL: data)
            let airQualityDictionary: NSDictionary =
            NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as! NSDictionary //casting
            
            let currentAir = CurrentAirQuality(airQualityDictionary: airQualityDictionary, currentLatitude: currentLatitude, currentLongitude: currentLongitude, last24Hours: last24Hours)
      
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.stationID = currentAir.closestStationID
                println("closest id is \(self.stationID)")

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
                dispatch_async(dispatch_get_main_queue()) {
                    println("sending data to struct from MVC")
                    let location = LocationForList(description: "Current Location", AQI: "\(self.airQuality)", lat: self.latitude, long: self.longitude, temp: self.currentTemperature, Oz: self.currentOzone)
                    LocationStore.sharedInstance.add(location)
                    println("##################################")
                }
            }
            placesTask.resume()
        }

func getMostRecentValue(channelsDict: NSDictionary, identifier: String){
    println("in getMostRecentValue()...")
    let temp: NSDictionary = channelsDict[identifier] as! NSDictionary
    let mRDS = temp["mostRecentDataSample"] as! NSDictionary
    self.airQuality  = mRDS["value"] as! Int
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
                
                let currentWeather = Current(weatherDictionary: weatherDictionary)
                
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let location = LocationStore.sharedInstance.get(indexPath.row)
                (segue.destinationViewController as! DetailViewController).detailItem = location
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationStore.sharedInstance.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomTableViewCell", forIndexPath: indexPath) as! CustomTableViewCell
        let location = LocationStore.sharedInstance.get(indexPath.row)

        cell.cityLabel?.text = location.description
        cell.aqiLabel?.text = location.AQI
        if (location.description == "Current Location"){
            cell.temperatureLabel?.text = self.currentTemperature
        }
        else{
            cell.temperatureLabel?.text = location.temp
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            LocationStore.sharedInstance.removeTaskAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
}
