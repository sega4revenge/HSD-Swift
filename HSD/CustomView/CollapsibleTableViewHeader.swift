//
//  a.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/29/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(header: CollapsibleTableViewHeader, section: Int)
}
class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    let titleLabel = UILabel()
    let arrowLabel = UILabel()
    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
          let marginGuide = contentView.layoutMarginsGuide
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHeader(tapGestureRecognizer:)))
        addGestureRecognizer(tapGestureRecognizer)
        self.backgroundView = UIView(frame: self.bounds)
        self.backgroundView?.backgroundColor = UIColor.white
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor,constant: 5).isActive = true
       
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func tapHeader(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let cell = tapGestureRecognizer.view as? CollapsibleTableViewHeader else {
            return
        }
       
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
}
