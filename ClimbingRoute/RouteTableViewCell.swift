//
//  RouteTableViewCell.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 27/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    @IBOutlet var createrLabel: UILabel!
    @IBOutlet var difficultyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
