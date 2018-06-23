//
//  CornerTextField.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/4/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit

class CornerTextField: UITextField {
    
    @IBInspectable var position: CGFloat = 0
    @IBInspectable var radius: CGFloat = 0
    let kLoginButtonBackgroundColor = UIColor.self(displayP3Red: 255/255, green: 160/255, blue: 0/255, alpha: 1)
    let kLoginButtonTintColor = UIColor.black
    let kLoginButtonCornerRadius: CGFloat = 5.0
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    private func configureUI() {
        self.layer.cornerRadius = radius
        self.backgroundColor = kLoginButtonBackgroundColor
        self.tintColor = kLoginButtonTintColor
        self.layer.borderColor = UIColor.black.cgColor
     
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch (position) {
        case 0 :
            self.configureUI()
            
        case 1:
            self.roundCorners([.topLeft, .bottomLeft], radius: 20)
        case 2:
            self.roundCorners([.topRight, .bottomRight], radius: 20)
        case 3:
            self.roundCorners([.bottomLeft, .bottomRight], radius: 20)
        default:
            self.layer.cornerRadius = radius
        }
        
    }
}
