//
//  SearchResultCell.swift
//  Ugo
//
//  Created by Sadiq on 13/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblModel: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func cell() ->  SearchResultCell
    {
        var nib:NSArray = NSBundle.mainBundle().loadNibNamed("SearchResultCell", owner: self, options: nil)
        var cell = nib.objectAtIndex(0) as?  SearchResultCell
        return cell!
    }
}
