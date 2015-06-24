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
    var aqiCategory: String = ""
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        makeSettingsIcon()
        getCurrentGeocode()
        getCurrentWeatherData()
        getCurrentAirQuality()
        super.viewDidLoad()
    }
    
    //MARK: - function to transform the settings button into the settings icon
    func makeSettingsIcon(){
        self.settingsButton.title = NSString(string: "\u{2699}") as String
        if let font = UIFont(name: "Helvetica", size: 24.0) {
            self.settingsButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
    }
    
    //MARK: - gets current coordinates
    func getCurrentGeocode() -> Void {
        
        setupLocation() //finds the current lat and long
        var currentLatitude = latitude
        var currentLongitude = longitude
        
        var apiNamesURL = "http://api.geonames.org/findNearbyPlaceNameJSON?lat=\(currentLatitude)&lng=\(currentLongitude)&username=airvizdev1"
        let currentGeocodeURL = NSURL(string: apiNamesURL)
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(currentGeocodeURL!, completionHandler: {
            (data: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            if(error != nil) {
                println(error.localizedDescription) //for Debugging
                let issue = UIAlertController(title: "Error", message: "Error in connection", preferredStyle: .Alert)
                let okIssue = UIAlertAction(title: "OK", style: .Default, handler: nil)
                issue.addAction(okIssue)
                let cancelIssue = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                issue.addAction(cancelIssue)
                self.presentViewController(issue, animated: true, completion: nil)
            }
            else {
                let dataObject = NSData(contentsOfURL: data)
                if let geoCodeDict: NSDictionary =
                    NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as? NSDictionary{
                
                    let currentLocality = CurrentGeocode(geoCodeDictionary: geoCodeDict)
                    self.currentLocation = "\(currentLocality.name)"
                }
            }
        })
        downloadTask.resume()
    }
    
    //MARK: - Finds current latitude and longitude
    func setupLocation(){
        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.requestAlwaysAuthorization()//####################
        if (CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//            locationManager.requestAlwaysAuthorization()
            
            //MN: ask about distance filter #########################################
            locationManager.distanceFilter = 1000
            
            //MN: ask about start and significant change #####################################
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

            let dataObject = NSData(contentsOfURL: data)
            if let airQualityDictionary: NSDictionary =
                NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as? NSDictionary{
            
                let AQ = CurrentAirQuality(airQualityDictionary: airQualityDictionary, currentLatitude: self.latitude, currentLongitude: self.longitude, last24Hours: last24Hours)
          
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.stationID = AQ.closestStationID
                    //now calling getAQI, which will invoke the getMostRecentValue method using the stationID
                    self.getMostRecentAQ()
                })
            }
        })
        downloadTask.resume()
    }
    
    //MARK: - creates the bounding box based on discussions with Chris Bartley and Mike Tasota and research from online sources
    func createBoundingBox(currentLatitude: Double, currentLongitude: Double) -> (Double, Double, Double, Double){
        var channelDistance = 10 //in kilometers
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
            self.airQuality = Int.min //this means it will display as NA
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
                        if let channels = data["channels"] as? NSDictionary {
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
                                self.airQuality = Int.min
                                self.aqiCategory = "Not Available"
                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    var finalAQI: String = ""
                    if (self.airQuality == Int.min){
                        finalAQI = "N/A"
                    }
                    else{
                        finalAQI = "\(self.airQuality)"
                    }
                    let location = LocationForList(description: "Current Location", AQI: finalAQI, lat: self.latitude, long: self.longitude, temp: self.currentTemperature, Oz: self.currentOzone, aqiCategory: self.aqiCategory)
                    LocationStore.sharedInstance.add(location)
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
        let aQ  = mostRecentDataSample["value"] as! Int
        let AQIData  = ConvertToAQI(pmValue: aQ) //converts the PM value to AQI
        self.aqiCategory = AQIData.category
        self.airQuality = AQIData.AQI
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
                    if let weatherDictionary: NSDictionary =
                        NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as? NSDictionary{
                        let currentWeather = CurrentWeather(weatherDictionary: weatherDictionary)
                        var temperatureSymbol: String
                        //based on user defined settings
                        if (SettingsViewController.variables.unit){                         temperatureSymbol = "\u{00B0} F" //symbol for degree F
                        }
                        else{
                            temperatureSymbol = "\u{00B0} C" //symbol for degree C
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.currentTemperature = "\(currentWeather.temperature)" + "\(temperatureSymbol)"
                            self.currentOzone = "\(currentWeather.ozone)"
                        })
                    }
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
        cell.aqiCategoryLabel?.text = location.aqiCategory
        cell.aqiCategoryLabel?.textColor = findAQICategoryColor(location.aqiCategory)
        return cell
    }
    
    //MARK: - finds the color of the AQI based on EPA's guidelines: http://airnow.gov/index.cfm?action=aqibasics.aqi
    func findAQICategoryColor(aqi: String) -> UIColor{
    
        var aqiCategoryColor: UIColor
    
        switch aqi{
        case "Good":
            aqiCategoryColor = UIColor.greenColor()
        case "Moderate":
            aqiCategoryColor = UIColor.yellowColor()
        case "Unhealthy for Sensitive Groups":
            aqiCategoryColor = UIColor.orangeColor()
        case "Unhealthy":
            aqiCategoryColor = UIColor.redColor()
        case "Very Unhealthy":
            aqiCategoryColor = UIColor.purpleColor()
        case "Hazardous":
            aqiCategoryColor = UIColor(red: 0.513, green: 0.011, blue: 0.0, alpha: 1.0) //maroon
        default:
            aqiCategoryColor = UIColor.blackColor()
        }
        return aqiCategoryColor
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
