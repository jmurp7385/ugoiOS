//
//  ProductListCell.swift
//  Ugo
//
//  Created by Sadiq on 04/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class ProductListCell: UITableViewCell ,UICollectionViewDataSource,UICollectionViewDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblMsg: UILabel!

    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    let CONST_cellItemSize = CGSizeMake(110, 149)
    var products : [Product]!
    var category : Category?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        flowLayout.itemSize = CONST_cellItemSize
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionStyle = UITableViewCellSelectionStyle.None
        collectionView.reloadData()
        if category?.scollToIndexPath != nil {
            collectionView.scrollToItemAtIndexPath(category!.scollToIndexPath!, atScrollPosition: UICollectionViewScrollPosition.Right, animated: false)
            category?.scollToIndexPath = nil
        }

    }
    
    // MARK: - Collection Delegates
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCollectionViewCell", forIndexPath: indexPath) as! ProductCollectionViewCell
        var product = products[indexPath.row]
        cell.imgProduct.setImageWithUrl(NSURL(string: product.thumb_image!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!, placeHolderImage: UIImage(named: "loading"))
        cell.lblName.text = product.name!
        cell.lblPrice.text = product.price!
        if let separator = cell.vwSeparator {
            separator.backgroundColor = UIColor(r: 85, g: 160, b: 68, a: 1)
        }

        
        

        
        if CommonUtility.isNetworkAvailable() {
            if products.count-1 == indexPath.row {
                category?.page += 1
                if category != nil && category!.isCallAPI {
                    category!.scollToIndexPath = indexPath
                    NSNotificationCenter.defaultCenter().postNotificationName("endOfProductList", object: category)
                }
            }
        }
        
        
        return cell
    }
    
    
        func collectionView(collectionView : UICollectionView,layout  collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
        {
            return CONST_cellItemSize
        }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0) // top, left, bottom, right
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        (collectionView.cellForItemAtIndexPath(indexPath) as! ProductCollectionViewCell).vwSeparator.backgroundColor = UIColor.redColor()
        NSNotificationCenter.defaultCenter().postNotificationName("didSelectCell", object: products[indexPath.row])
    }
    
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        var cell =  (collectionView.cellForItemAtIndexPath(indexPath) as? ProductCollectionViewCell)
        cell?.vwSeparator.backgroundColor = UIColor(r: 85, g: 160, b: 68, a: 1)
    }
    

}
