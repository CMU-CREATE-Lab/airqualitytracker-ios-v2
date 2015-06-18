//
//  CustomTableViewCell.swift
//  V3
//
//  Created by Mohak Nahta  on 6/17/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var aqiLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
