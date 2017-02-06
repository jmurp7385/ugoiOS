//
//  PaymentSelectCell.swift
//  Ugo
//
//  Created by Sadiq on 24/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class SelectBoxCell: UITableViewCell {
    @IBOutlet weak var txtSelect: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        txtSelect.backgroundColor = UIColor(r: 219, g: 219, b: 219, a: 1)
        txtSelect.layer.shadowColor = UIColor.blackColor().CGColor
        txtSelect.layer.shadowOpacity = 0.5
        txtSelect.layer.shadowRadius = 1
        
        txtSelect.layer.shadowOffset = CGSizeMake(0.5 , 0.5)
        txtSelect.layer.cornerRadius = 3
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
