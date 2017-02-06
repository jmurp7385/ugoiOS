//
//  SelectQtyViewController.swift
//  Tokri
//
//  Created by Sadiq on 11/05/15.
//  Copyright (c) 2015 Xstpl. All rights reserved.
//

import UIKit

protocol SelectQtyViewControllerDelegate {
    func receivedSelectedQty(_ sku: String)
}

class SelectQtyViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    var delegate : SelectQtyViewControllerDelegate!
    var quantityArr : [String] = []
    var product : Product!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SelectQtyViewController.Done(_:)))
        self.bgView.gestureRecognizers = [gesture]
        tableView.contentInset = UIEdgeInsets.zero
        for i in 1..<16
        {
            quantityArr.append("\(i)")
        }
        var height = 5
        if quantityArr.count > 5 {
            tableView.isScrollEnabled = true
        }else {
            height = quantityArr.count
        }
        
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.width, height: CGFloat(44 * height + 44))
         tableView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        
        
//        tableView.backgroundColor = self.view.backgroundColor
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 1
        tableView.layer.shadowRadius = 5
        
        tableView.layer.shadowOffset = CGSize(width: 1 , height: 1)
        tableView.layer.cornerRadius = 10
        

        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- gesture function
    func Done(_ sender:UITapGestureRecognizer?){
        let vw =  self.parent
        
        let vc = vw!.childViewControllers.last as? SelectQtyViewController
        
        vc?.willMove(toParentViewController: nil)
        vc?.view.removeFromSuperview()
        vc?.removeFromParentViewController()
        
//          NSNotificationCenter.defaultCenter().postNotificationName("removeSelectView", object: nil, userInfo: nil)
       
    }
    
    //MARK:- Tableview Delegates
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(r: 66, g: 140, b: 54, a: 1)
        label.textAlignment = NSTextAlignment.center
        label.text = "Select Quantity"
        
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return quantityArr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        product.setDefaultSku(quantityArr[indexPath.row])
//
        delegate.receivedSelectedQty(quantityArr[indexPath.row])
        Done(nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? UITableViewCell
        
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
