//
//  SelectQtyViewController.swift
//  Tokri
//
//  Created by Sadiq on 11/05/15.
//  Copyright (c) 2015 Xstpl. All rights reserved.
//

import UIKit

protocol SelectQtyViewControllerDelegate {
    func receivedSelectedQty(sku: String)
}

class SelectQtyViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    var delegate : SelectQtyViewControllerDelegate!
    var quantityArr : [String] = []
    var product : Product!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        var gesture = UITapGestureRecognizer(target: self, action: Selector("Done:"))
        self.bgView.gestureRecognizers = [gesture]
        tableView.contentInset = UIEdgeInsetsZero
        for i in 1..<16
        {
            quantityArr.append("\(i)")
        }
        var height = 5
        if quantityArr.count > 5 {
            tableView.scrollEnabled = true
        }else {
            height = quantityArr.count
        }
        
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.width, CGFloat(44 * height + 44))
         tableView.center = CGPointMake(UIScreen.mainScreen().bounds.width/2, UIScreen.mainScreen().bounds.height/2)
        
        
//        tableView.backgroundColor = self.view.backgroundColor
        tableView.layer.shadowColor = UIColor.blackColor().CGColor
        tableView.layer.shadowOpacity = 1
        tableView.layer.shadowRadius = 5
        
        tableView.layer.shadowOffset = CGSizeMake(1 , 1)
        tableView.layer.cornerRadius = 10
        

        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- gesture function
    func Done(sender:UITapGestureRecognizer?){
        var vw =  self.parentViewController
        
        let vc = vw!.childViewControllers.last as? SelectQtyViewController
        
        vc?.willMoveToParentViewController(nil)
        vc?.view.removeFromSuperview()
        vc?.removeFromParentViewController()
        
//          NSNotificationCenter.defaultCenter().postNotificationName("removeSelectView", object: nil, userInfo: nil)
       
    }
    
    //MARK:- Tableview Delegates
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var label = UILabel(frame: CGRectMake(0, 0, tableView.frame.width, tableView.frame.height))
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor(r: 66, g: 140, b: 54, a: 1)
        label.textAlignment = NSTextAlignment.Center
        label.text = "Select Quantity"
        
        return label
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return quantityArr.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        product.setDefaultSku(quantityArr[indexPath.row])
//
        delegate.receivedSelectedQty(quantityArr[indexPath.row])
        Done(nil)
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
//        var quantity = "\(quantityArr[indexPath.row].pack_size!) \(quantityArr[indexPath.row].unit_name!)"

        cell!.textLabel?.textAlignment = .Center
        cell!.textLabel?.text = quantityArr[indexPath.row]
        
        // Configure the cell...
        
        return cell!
    }
    
    
    
}
