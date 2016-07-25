//
//  DropDownCell.swift
//  Yelp
//
//  Created by Guru Vijayakumar on 7/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class DropDownCell: UITableViewCell {

    @IBOutlet weak var ddLabel: UILabel!
    
    @IBOutlet weak var ddImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
