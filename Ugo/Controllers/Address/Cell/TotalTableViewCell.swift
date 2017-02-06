//
//  TotalTableViewCell.swift
//  Ugo
//
//  Created by Sadiq on 19/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class TotalTableViewCell: UITableViewCell {
    @IBOutlet weak var lblLabel: UILabel!
    @IBOutlet weak var lblValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) { //added '_'
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
