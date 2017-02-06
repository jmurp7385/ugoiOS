//
//  MenuCell.swift
//  Ugo
//
//  Created by Sadiq on 30/07/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgLeftIcon: UIImageView!
    
    @IBOutlet weak var lblNotificationCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //lblNotificationCount._गोल_करा
        lblName.highlightedTextColor = UIColor.white
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(r: 66, g: 154, b: 43, a: 1)
        self.selectedBackgroundView = bgView
        
        lblNotificationCount.layer.backgroundColor = UIColor.red.cgColor
        // Configure the view for the selected state
    }

}
