//
//  ProductTableViewCell.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/1/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var cell: UIView!
  
    @IBOutlet weak var back_view: UIView!
    
    @IBOutlet weak var UI_expired: UILabel!
    @IBOutlet weak var UI_name: UILabel!
    @IBOutlet weak var UI_time: UILabel!
    @IBOutlet weak var UI_image: UIImageView!
    @IBOutlet weak var UI_barcode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
