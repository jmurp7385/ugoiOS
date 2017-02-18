//
//  CartTableViewCell.swift
//  Ugo
//
//  Created by Sadiq on 17/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class CartTableViewCell: SWTableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var btnSelectQty: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func layoutSubviews() {

        super.layoutSubviews()
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.contentView.frame = self.bounds
        bgView.layer.shadowColor = UIColor(r: 0, g: 0, b: 0, a: 0.5).cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bgView.layer.shadowOpacity = 1
        bgView.layer.shadowRadius = 5.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       

        // Configure the view for the selected state
    }
    
    
   

}
