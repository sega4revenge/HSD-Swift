//
//  NotificationViewCell.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/18/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit

class NotificationViewCell: UITableViewCell {
    
    @IBOutlet weak var UI_cell: UIView!
    
    @IBOutlet weak var UI_image: UIImageView!
    @IBOutlet weak var UI_content: UILabel!
    @IBOutlet weak var UI_time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
