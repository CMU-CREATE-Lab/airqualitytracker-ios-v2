//
//  AddTaskViewController.swift
//  V3
//
//  Created by Mohak Nahta  on 6/9/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import UIKit

var searcher : UISearchController!


class AddTaskViewController: UIViewController, UISearchBarDelegate {
    
    var descriptionLabel: String! = ""
    var coordinateLabel: String! = ""
    
    @IBOutlet weak var searchBarView: UIView!
    
    let googleAPI = GoogleAPI()
    let src = AutoCompleteController()
    
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
        println("in search is finished: Search Bar Search Button Clicked")
        searcher.active = false
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar){
        println("in searchBarTextDidEndEditing")
        if src.selected! {
            var positionInArray = src.selectedIndex.row
            descriptionLabel = src.areaNamesArray[positionInArray]
            
            googleAPI.fetchPlacesDetail(src.placeIdArray[positionInArray]){ place in
                self.coordinateLabel = "lat,lon \(place!.coordinate.latitude), \(place!.coordinate.longitude)"
            }
            performSegueWithIdentifier("dismissAndSave", sender: self)

        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        performSegueWithIdentifier("dismissAndCancel", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "dismissAndSave" {
//            if (description == "" || placeID == ""){
            let location = LocationForList(description: descriptionLabel, coordinate: coordinateLabel)
            LocationStore.sharedInstance.add(location)
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}