//
//  DetailViewController.swift
//  V3
//
//  Created by Mohak Nahta  on 6/8/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//


//IDEA FOR current location bug: initialize with a variable Current Location. then when the user clicks it, it goes to the detail view controller. there refresh the location just like you did in V2 and then display it. That way, no problem refreshing. But do this after the normal detail view controller is working.

import UIKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var airQualityStationID: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var ozoneLabel: UILabel!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    
    var detailItem: LocationForList? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: LocationForList = self.detailItem {
            if let locationName = self.detailDescriptionLabel {
                locationName.text = detail.description
                self.airQualityStationID.text = detail.AQI
                latitude = detail.lat
                longitude = detail.long
            }
        }
    }
    
    override func viewDidLoad() {
        
        self.configureView()
        getCurrentWeatherData()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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

                    self.temperatureLabel.text = "\(currentWeather.temperature)" + "\(temperatureSymbol)"
//                      self.summaryLabel.text = "\(currentWeather.summary)"
                    self.ozoneLabel.text = "\(currentWeather.ozone)"
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
    
    
}

