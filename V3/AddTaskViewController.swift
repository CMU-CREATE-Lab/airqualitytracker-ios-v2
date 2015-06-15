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
        var last24Hours = currentDateInSeconds - (60 * 60 * 24)
        
        var (latMin, latMax, lonMin, lonMax) = createBoundingBox(currentLatitude, currentLongitude: currentLongitude)
        
        
        let airQualityURL = NSURL(string: "https://esdr.cmucreatelab.org/api/v1/feeds?whereAnd=productId=11,latitude%3E=\(latMin),latitude%3C=\(latMax),longitude%3E=\(lonMin),longitude%3C=\(lonMax),maxTimeSecs%3E=\(last24Hours)&fields=id,name,latitude,longitude,channelBounds")
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(airQualityURL!, completionHandler: { (data: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
        
                let dataObject = NSData(contentsOfURL: data)
                let airQualityDictionary: NSDictionary =
                NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as! NSDictionary //casting
                
                let currentAir = CurrentAirQuality(airQualityDictionary: airQualityDictionary, currentLatitude: currentLatitude, currentLongitude: currentLongitude)
            
            //sync because need to complete this process before any other thread is executed
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.AQILabel = "\(currentAir.closestStationID)"
                    let location = LocationForList(description: self.descriptionLabel, AQI: self.AQILabel)
                    LocationStore.sharedInstance.add(location)
                })
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