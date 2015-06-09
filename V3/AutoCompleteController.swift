//
//  AutoCompleteController.swift
//  SearchController
//
//  Created by Mohak Nahta on 06/03/2015. Hints and partial code used from https://github.com/wiserkuo/Swift-SearchController

import UIKit

class AutoCompleteController: UITableViewController {
    var areaNamesArray : [String] = []
    var placeIdArray : [String] = []
    var filteredData : [String] = []
    var googleAPI = GoogleAPI()
    var selectedIndex = NSIndexPath()
    var selected : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //1 is based on trial and error
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = self.filteredData[indexPath.row]
        
        return cell
    }
    override func tableView(tableView: UITableView,didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex=indexPath
        selected = true
        searcher.active=false
        
    }
    
    
}

extension AutoCompleteController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        selected = false
        self.areaNamesArray.removeAll()
        self.placeIdArray.removeAll()
        googleAPI.fetchPlacesAutoComplete(searchController.searchBar.text){ predictions in
            for prediction: NameAndID in predictions {
                self.areaNamesArray.append(prediction.description)
                self.placeIdArray.append(prediction.place_id)
            }
            
            self.filteredData = self.areaNamesArray
            
            self.tableView.reloadData()
        }
    }
}
