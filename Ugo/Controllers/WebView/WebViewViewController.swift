//
//  WebViewViewController.swift
//  Ugo
//
//  Created by Sadiq on 10/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class WebViewViewController: UIViewController ,UIWebViewDelegate,NJKWebViewProgressDelegate{
    
    @IBOutlet weak var webView: UIWebView!
    var strUrl:String!
    
    @IBOutlet var vwTitle: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUrl: UILabel!
    @IBOutlet weak var progressView : NJKWebViewProgressView!
    var progressProxy:NJKWebViewProgress?
    
    
    var pageCnt:Int = 0
    
    var isPayment = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        
        if isPayment {
            self.navigationItem.leftBarButtonItem = customBarBtn(25, height: 25, imgName: "web_close", actionName: "btnCloseTapped")

        }else{
            var btnRefreshItem = UIBarButtonItem(image: UIImage(named: "web_refresh"), style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("btnRefreshTapped"))
            
            var btnMenuItem = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("btnMenuTapped"))
         
            
            self.navigationItem.rightBarButtonItem = btnRefreshItem
            self.navigationItem.leftBarButtonItem = btnMenuItem
        }
        
        
        
        
        if !(strUrl.hasPrefix("http://") || strUrl.hasPrefix("https://")) {
            strUrl = "http://\(strUrl)"
        }
        
        progressProxy = NJKWebViewProgress()
        webView.delegate = progressProxy
        progressProxy?.webViewProxyDelegate = self
        progressProxy?.progressDelegate = self
        
        var req  = NSURLRequest(URL: NSURL(string: strUrl)!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 3000.0)
        webView.loadRequest(req)
        // Do any additional setup after loading the view.
    }
    
    func btnCloseTapped(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setCloseButton() {
        self.navigationItem.leftBarButtonItem = customBarBtn(25, height: 25, imgName: "web_close", actionName: "btnCloseTapped")
    }
    
    func customBarBtn(width:CGFloat, height:CGFloat, imgName:String, actionName:String) -> UIBarButtonItem {
        var replyBtn = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        replyBtn.setImage(UIImage(named: imgName), forState: UIControlState.Normal)
        replyBtn.addTarget(self, action: Selector(actionName), forControlEvents:  UIControlEvents.TouchUpInside)
        
        return UIBarButtonItem(customView: replyBtn)
    }
    
    
    // MARK: Btn taps
    // ^^^^^^^^^^^^^^
    
    func btnMenuTapped(){
        self.revealViewController().revealToggleAnimated(true)
    }
    
    func btnStopTapped() {
        webView.stopLoading()
        //        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func btnRefreshTapped() {
        webView.reload()
    }
    
    func btnPreTapped() {
        if self.webView.canGoBack {
            pageCnt -= 1
            self.webView.goBack()
        }
    }
    
    func btnNextTapped() {
        if self.webView.canGoForward {
            pageCnt += 1
            self.webView.goForward()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(animated: Bool) {
        
        if webView != nil {
            if webView.loading == true
            {
                webView.stopLoading()
            }
            self.webView.delegate = nil
            self.webView = nil
        }
        super.viewWillDisappear(animated)
    }
    
    func setLeftBarButtons(val:Bool) {
        if val {
            if self.navigationItem.leftBarButtonItems?.count != 2 {
                
                var btnPreItem = UIBarButtonItem(image: UIImage(named: "web_back"), style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("btnPreTapped"))
               
                var btnNextItem = UIBarButtonItem(image: UIImage(named: "web_next"), style:
                    UIBarButtonItemStyle.Bordered, target: self, action: Selector("btnNextTapped"))
                
                
                var btnMenuItem = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("btnMenuTapped"))
        

                self.navigationItem.leftBarButtonItem = isPayment ? customBarBtn(25, height: 25, imgName: "web_close", actionName: "btnCloseTapped") : btnMenuItem

                
                
                //                lblTitle.textAlignment = .Center
                //                lblUrl.textAlignment = .Center
            }
        } else {
            self.navigationItem.leftBarButtonItems = []
            //            lblTitle.textAlignment = .Left
            //            lblUrl.textAlignment = .Left
        }
    }
    
    
    // MARK: WebVIew Delegates
    // ^^^^^^^^^^^^^^^^^^^^^^^
    
    func webViewDidStartLoad(webView: UIWebView) {
        
        
        var url = webView.request?.mainDocumentURL
        //print(url)
        
        
        if (webView.canGoBack || webView.canGoForward){
            setLeftBarButtons(true)
        } else if !webView.canGoBack{
            //setLeftBarButtons(false)
        }
        
        if self.navigationItem.leftBarButtonItems?.count > 1 {
            var btnBack = self.navigationItem.leftBarButtonItems?[1] as? UIBarButtonItem
            var btnForward = self.navigationItem.leftBarButtonItems?[2] as? UIBarButtonItem
            
            
            if webView.canGoBack || pageCnt > 0 {
                btnBack?.enabled = true
            } else {
                btnBack?.enabled = false
            }
            if webView.canGoForward{
                btnForward?.enabled = true
            } else {
                btnForward?.enabled = false
            }
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.navigationItem.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        //        lblTitle.text = webView.stringByEvaluatingJavaScriptFromString("document.title")
        //        lblUrl.text = webView.stringByEvaluatingJavaScriptFromString("document.domain")
        
        if self.navigationItem.leftBarButtonItems?.count > 1 {
            var btnBack = self.navigationItem.leftBarButtonItems?[1] as? UIBarButtonItem
            var btnForward = self.navigationItem.leftBarButtonItems?[2] as? UIBarButtonItem
            
            if webView.canGoBack {
                btnBack?.enabled = true;
            } else {
                btnBack?.enabled = false;
            }
            
            if webView.canGoForward{
                
                btnForward?.enabled = true;
            } else {
                btnForward?.enabled = false;
            }
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if isPayment {
            var str = request.mainDocumentURL?.URLString
            if let contains = str?.rangeOfString("checkout/success"){
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.loadSuccessPage()
                })
                
                return false
            } else if let contains = str?.rangeOfString("checkout/cart"){
                self.dismissViewControllerAnimated(true, completion: nil)
                return false
            }
            
            //println(request.mainDocumentURL?.URLString)
        }
        return true
    }
    
    func loadSuccessPage(){
        var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CheckoutSuccessController") as! CheckoutSuccessController
        var nav = UINavigationController(rootViewController: vc)
        UIApplication.sharedApplication().keyWindow?.topMostController()!.presentViewController(nav, animated: true, completion: nil)
        
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: NJ web del
    // ^^^^^^^^^^^^^^^^
    func webViewProgress(webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        progressView.setProgress(progress, animated:true)
    }
    
    
    
}
