//
//  DetailViewController.swift
//  V3
//
//  Created by Mohak Nahta  on 6/8/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//


//IDEA FOR current location bug: initialize with a variable Current Location. then when the user clicks it, it goes to the detail view controller. there refresh the location just like you did in V2 and then display it. That way, no problem refreshing. But do this after the normal detail view controller is working.

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    
    var detailItem: LocationForList? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: LocationForList = self.detailItem {
            if let name = self.detailDescriptionLabel {
                name.text = detail.description
                let coordinates = detail.coordinate
                println("in detailViewController \(detail.coordinate)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

