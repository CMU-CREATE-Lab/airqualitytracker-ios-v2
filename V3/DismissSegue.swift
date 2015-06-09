//
//  DismissSegue.swift
//  V3
//
//  Created by Mohak Nahta  on 6/9/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import UIKit


@objc(DismissSegue) class DismissSegue: UIStoryboardSegue {

    override func perform() {
        if let controller = sourceViewController.presentingViewController {
            controller!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}