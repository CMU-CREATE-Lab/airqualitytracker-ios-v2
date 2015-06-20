//
//  CustomTableViewCell.swift
//  V3
//
//  Created by Mohak Nahta  on 6/17/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import UIKit

//class for the cells in master view controller
class CustomTableViewCell: UITableViewCell {

    @IBOutlet var aqiLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
