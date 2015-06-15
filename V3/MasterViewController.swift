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

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        
        getCurrentLocality()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
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
            //            locationManager.startMonitoringSignificantLocationChanges()
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
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.currentLocation = "\(currentLocality.name),\(currentLocality.stateCode)"
                    println("currentLocation is \(self.currentLocation)")
                    let initialLocation = LocationForList(description: self.currentLocation, coordinate: "\(currentLatitude),\(currentLongitude)")
                    LocationStore.sharedInstance.add(initialLocation)
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
    
    func refresh() {
        getCurrentLocality()

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
        cell.detailTextLabel?.text = location.coordinate
        
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


//// MARC :- original master view controller 
////  MasterViewController.swift
////  V3
////
////  Created by Mohak Nahta  on 6/8/15.
////  Copyright (c) 2015 Speck Sensor. All rights reserved.
////
//
////IMPORTANT: see https://teamtreehouse.com/forum/swift-weather-app-reload-data
//
//import UIKit
//
//class MasterViewController: UITableViewController{
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    override func viewDidLoad() {
//    
//        let initialLocation = LocationForList(description: "Alcatraz Island, CA", coordinate: "40.4437514575563,-79.9465463763799")
//    
//        LocationStore.sharedInstance.add(initialLocation)
//        
//        // Do any additional setup after loading the view, typically from a nib.
//        
//        super.viewDidLoad()
//
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()
//    }
//
//   
//    
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//    // MARK: - Segues
//
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = self.tableView.indexPathForSelectedRow() {
//                let location = LocationStore.sharedInstance.get(indexPath.row)
//                (segue.destinationViewController as! DetailViewController).detailItem = location
//            }
//        }
//    }
//
//    // MARK: - Table View
//
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return LocationStore.sharedInstance.count
//    }
//
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
//
//        let location = LocationStore.sharedInstance.get(indexPath.row)
//        cell.textLabel?.text = location.description
//        cell.detailTextLabel?.text = location.coordinate
//        
//        return cell
//    }
//
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//
//    override func viewWillAppear(animated: Bool) {
//        self.tableView.reloadData()
////        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
//    }
//    
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            LocationStore.sharedInstance.removeTaskAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }
//
//}
//
