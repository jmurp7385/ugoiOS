//
//  PageCellTableViewCell.swift
//  Ugo
//
//  Created by Sadiq on 04/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class PageTableViewCell: UITableViewCell , UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var products : [Product] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func imgTapped(_ sender:UITapGestureRecognizer){
        let index = sender.view!.tag
        let product = products[index]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectCell"), object: product)

        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var xposition:CGFloat = 0
        for (index,product) in products.enumerated() {
        //for (index,product) in  enumerate(products) {
            let imgView = UIImageView(frame: CGRect(x: xposition, y: 0, width: ScreenSize.SCREEN_WIDTH, height: scrollView.frame.height))
            imgView.af_setImage(withURL: URL(string: product.thumb_image!.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)!)
            //imgView.setImageWithUrl(URL(string: product.thumb_image!.addingPercentEscapes(using: String.Encoding.utf8)!)!, placeHolderImage: nil)
            imgView.contentMode = UIViewContentMode.scaleAspectFit
            xposition = xposition + ScreenSize.SCREEN_WIDTH
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PageTableViewCell.imgTapped(_:)))
            imgView.tag = index
            imgView.gestureRecognizers = [tapGesture]
            imgView.isUserInteractionEnabled = true

            scrollView.addSubview(imgView)
            scrollView.bringSubview(toFront: imgView)
        }
        
        scrollView.contentSize = CGSize(width: xposition, height: scrollView.frame.height)
        scrollView.delegate = self

        let pages =  Int(scrollView.contentSize.width / ScreenSize.SCREEN_WIDTH)
//        //print("pages \(pages)")
        pageControl.numberOfPages = pages
        pageControl.addTarget(self, action: #selector(PageTableViewCell.changePage(_:)), for: UIControlEvents.valueChanged)
    }

    func changePage(_ sender:UIPageControl){
        let page : Int = sender.currentPage
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newOffset: CGFloat = scrollView.contentOffset.x
        let pageNumber = Int(newOffset/scrollView.frame.size.width)
        pageControl.currentPage = pageNumber
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = self.scrollView.frame.size.width
        let fractionalPage = self.scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionalPage))
        self.pageControl.currentPage = page
    }
}
