//
//  SelectAddressCell.swift
//  Ugo
//
//  Created by Sadiq on 19/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class SelectAddressCell: UITableViewCell {
    @IBOutlet weak var btnGetLocation: UIButton!
    @IBOutlet weak var btnAddAddress: UIButton!
    @IBOutlet weak var btnRecentAddress: UIButton!


    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        btnRecentAddress.backgroundColor = UIColor(r: 219, g: 219, b: 219, a: 1)
//        btnRecentAddress.layer.cornerRadius = 5

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
