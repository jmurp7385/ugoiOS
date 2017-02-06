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
    
    let CONST_cellItemSize = CGSize(width: 110, height: 149)
    var products : [Product]!
    var category : Category?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.itemSize = CONST_cellItemSize
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionStyle = UITableViewCellSelectionStyle.none
        collectionView.reloadData()
        if category?.scollToIndexPath != nil {
            collectionView.scrollToItem(at: category!.scollToIndexPath! as IndexPath, at: UICollectionViewScrollPosition.right, animated: false)
            category?.scollToIndexPath = nil
        }

    }
    
    // MARK: - Collection Delegates
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        var product = products[indexPath.row]
        cell.imgProduct.setImageWithUrl(URL(string: product.thumb_image!.addingPercentEscapes(using: String.Encoding.utf8)!)!, placeHolderImage: UIImage(named: "loading"))
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
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "endOfProductList"), object: category)
                }
            }
        }
        
        
        return cell
    }
    
    
        func collectionView(_ collectionView : UICollectionView,layout  collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:IndexPath) -> CGSize
        {
            return CONST_cellItemSize
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0) // top, left, bottom, right
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as! ProductCollectionViewCell).vwSeparator.backgroundColor = UIColor.red
        NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectCell"), object: products[indexPath.row])
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell =  (collectionView.cellForItem(at: indexPath) as? ProductCollectionViewCell)
        cell?.vwSeparator.backgroundColor = UIColor(r: 85, g: 160, b: 68, a: 1)
    }
    

}
