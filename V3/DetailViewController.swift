//
//  DetailViewController.swift
//  V3
//
//  Created by Mohak Nahta  on 6/8/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var airQualityStationID: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var ozoneLabel: UILabel!
    //boolean to indicate if Detail VC already has weather information or not
    var callCurrentWeather: Bool = false
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
                if (detail.description != "Current Location"){
                    self.temperatureLabel.text = detail.temp
                    self.ozoneLabel.text = detail.Oz
                    callCurrentWeather = false
                }
                else{
                    callCurrentWeather = true
                }
            }
        }
    }
    
    override func viewDidLoad() {
        
        self.configureView()
        if (callCurrentWeather){
            getCurrentWeatherData()
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: - gets the current weather data based on the coordinates
    func getCurrentWeatherData() -> Void {
        
        let forecastApiKey = "87224a504c9c40fe40c2166ff8fb846c"

        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(forecastApiKey)/")
        let forecastURL = NSURL(string: "\(latitude),\(longitude)", relativeToURL: baseURL)
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: {(location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                if (error != nil){
                    let issue = UIAlertController(title: "Error", message: "Error in connection", preferredStyle: .Alert)
                    
                    let okIssue = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    issue.addAction(okIssue)
                    
                    let cancelIssue = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                    issue.addAction(cancelIssue)
                    
                    self.presentViewController(issue, animated: true, completion: nil)
     
                }
            
                else{
                    let dataObject = NSData(contentsOfURL: location)
                    let weatherDict: NSDictionary =
                    NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as! NSDictionary
                    
                    let currentWeather = CurrentWeather(weatherDictionary: weatherDict)
                    
                    var temperatureSymbol: String
                    if (SettingsViewController.variables.unit){
                        temperatureSymbol = "\u{00B0} F" //symbol for degree F
                    }
                        
                    else{
                        temperatureSymbol = "\u{00B0} C" //symbol for degree C
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.temperatureLabel.text = "\(currentWeather.temperature)" + "\(temperatureSymbol)"
                        self.ozoneLabel.text = "\(currentWeather.ozone)"
                    })
                }
            
            })
        downloadTask.resume()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

