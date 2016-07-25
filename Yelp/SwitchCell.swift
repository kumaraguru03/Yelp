//
//  SwitchCell.swift
//  Yelp
//
//  Created by Guru Vijayakumar on 7/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol  SwitchCellDelegate {
    optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {
   
    @IBOutlet weak var switchLabel: UILabel!
    
    @IBOutlet weak var onSwitch: UISwitch!
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        onSwitch.addTarget(self, action: #selector(SwitchCell.switchValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchValueChanged() {
        delegate?.switchCell?(self, didChangeValue: onSwitch.on)
    }

}
