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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func imgTapped(sender:UITapGestureRecognizer){
        var index = sender.view!.tag
        var product = products[index]
        
        NSNotificationCenter.defaultCenter().postNotificationName("didSelectCell", object: product)

        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var xposition:CGFloat = 0
        
        for (index,product) in  enumerate(products) {
            var imgView = UIImageView(frame: CGRectMake(xposition, 0, ScreenSize.SCREEN_WIDTH, scrollView.frame.height))
            imgView.setImageWithUrl(NSURL(string: product.thumb_image!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!, placeHolderImage: nil)
            imgView.contentMode = UIViewContentMode.ScaleAspectFit
            xposition = xposition + ScreenSize.SCREEN_WIDTH
            
            
            var tapGesture = UITapGestureRecognizer(target: self, action: Selector("imgTapped:"))
            imgView.tag = index
            imgView.gestureRecognizers = [tapGesture]
            imgView.userInteractionEnabled = true

            scrollView.addSubview(imgView)
            scrollView.bringSubviewToFront(imgView)
        }
        
        scrollView.contentSize = CGSizeMake(xposition, scrollView.frame.height)
        scrollView.delegate = self

        var pages =  Int(scrollView.contentSize.width / ScreenSize.SCREEN_WIDTH)
//        //print("pages \(pages)")
        pageControl.numberOfPages = pages
        pageControl.addTarget(self, action: Selector("changePage:"), forControlEvents: UIControlEvents.ValueChanged)
    }

    func changePage(sender:UIPageControl){
        var page : Int = sender.currentPage
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var newOffset: CGFloat = scrollView.contentOffset.x
        var pageNumber = Int(newOffset/scrollView.frame.size.width)
        pageControl.currentPage = pageNumber
    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth = self.scrollView.frame.size.width
        var fractionalPage = self.scrollView.contentOffset.x / pageWidth
        var page = lround(Double(fractionalPage))
        self.pageControl.currentPage = page
    }
}
