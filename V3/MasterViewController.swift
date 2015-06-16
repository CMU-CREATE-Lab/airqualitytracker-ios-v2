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
    var airQuality: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        getCurrentLocality()
        getCurrentAirQuality()
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
        var last24Hours = currentDateInSeconds - (60 * 60 * 24)
        
        var (latMin, latMax, lonMin, lonMax) = createBoundingBox(currentLatitude, currentLongitude: currentLongitude)
        
        
        let airQualityURL = NSURL(string: "https://esdr.cmucreatelab.org/api/v1/feeds?whereAnd=productId=11,latitude%3E=\(latMin),latitude%3C=\(latMax),longitude%3E=\(lonMin),longitude%3C=\(lonMax),maxTimeSecs%3E=\(last24Hours)&fields=id,name,latitude,longitude,channelBounds")
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(airQualityURL!, completionHandler: { (data: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            let dataObject = NSData(contentsOfURL: data)
            let airQualityDictionary: NSDictionary =
            NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as! NSDictionary //casting
            
            let currentAir = CurrentAirQuality(airQualityDictionary: airQualityDictionary, currentLatitude: currentLatitude, currentLongitude: currentLongitude)
            
            self.airQuality = currentAir.closestStationID
            let location = LocationForList(description: "Current Location", AQI: "\(self.airQuality)", lat: self.latitude, long: self.longitude)
            LocationStore.sharedInstance.add(location)
        })
        
        downloadTask.resume()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let location = LocationStore.sharedInstance.get(indexPath.row)
        cell.textLabel?.text = location.description
        cell.detailTextLabel?.text = location.AQI
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        //        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
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
