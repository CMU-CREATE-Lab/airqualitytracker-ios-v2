//
//  AboutSpeckViewController.swift
//  V3
//
//  Created by Mohak Nahta  on 6/16/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import UIKit

class AboutSpeckViewController: UIViewController {

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    override func viewDidLoad() {
        
        //changing the settings button to a settings cog wheel logo
        self.settingsButton.title = NSString(string: "\u{2699}") as String
        if let font = UIFont(name: "Helvetica", size: 24.0) {
            self.settingsButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
