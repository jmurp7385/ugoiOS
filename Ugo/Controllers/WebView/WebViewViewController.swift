//
//  WebViewViewController.swift
//  Ugo
//
//  Created by Sadiq on 10/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        
        if isPayment {
            self.navigationItem.leftBarButtonItem = customBarBtn(25, height: 25, imgName: "web_close", actionName: "btnCloseTapped")

        }else{
            let btnRefreshItem = UIBarButtonItem(image: UIImage(named: "web_refresh"), style: UIBarButtonItemStylePlain, target: self, action: #selector(WebViewViewController.btnRefreshTapped))
            
            let btnMenuItem = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItemStylePlain, target: self, action: #selector(WebViewViewController.btnMenuTapped))
         
            
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
        
        let req  = Foundation.URLRequest(url: URL(string: strUrl)!, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 3000.0)
        webView.loadRequest(req)
        // Do any additional setup after loading the view.
    }
    
    func btnCloseTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setCloseButton() {
        self.navigationItem.leftBarButtonItem = customBarBtn(25, height: 25, imgName: "web_close", actionName: "btnCloseTapped")
    }
    
    func customBarBtn(_ width:CGFloat, height:CGFloat, imgName:String, actionName:String) -> UIBarButtonItem {
        let replyBtn = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        replyBtn.setImage(UIImage(named: imgName), for: UIControlState())
        replyBtn.addTarget(self, action: Selector(actionName), for:  UIControlEvents.touchUpInside)
        
        return UIBarButtonItem(customView: replyBtn)
    }
    
    
    // MARK: Btn taps
    // ^^^^^^^^^^^^^^
    
    func btnMenuTapped(){
        self.revealViewController().revealToggle(animated: true)
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
    override func viewWillDisappear(_ animated: Bool) {
        
        if webView != nil {
            if webView.isLoading == true
            {
                webView.stopLoading()
            }
            self.webView.delegate = nil
            self.webView = nil
        }
        super.viewWillDisappear(animated)
    }
    
    func setLeftBarButtons(_ val:Bool) {
        if val {
            if self.navigationItem.leftBarButtonItems?.count != 2 {
                
                var btnPreItem = UIBarButtonItem(image: UIImage(named: "web_back"), style: UIBarButtonItemStylePlain, target: self, action: #selector(WebViewViewController.btnPreTapped))
               
                var btnNextItem = UIBarButtonItem(image: UIImage(named: "web_next"), style:
                    UIBarButtonItemStylePlain, target: self, action: #selector(WebViewViewController.btnNextTapped))
                
                
                let btnMenuItem = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItemStylePlain, target: self, action: #selector(WebViewViewController.btnMenuTapped))
        

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
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        
        _ = webView.request?.mainDocumentURL
        //print(url)
        
        
        if (webView.canGoBack || webView.canGoForward){
            setLeftBarButtons(true)
        } else if !webView.canGoBack{
            //setLeftBarButtons(false)
        }
        
        if self.navigationItem.leftBarButtonItems?.count > 1 {
            let btnBack = self.navigationItem.leftBarButtonItems?[1] as UIBarButtonItem!
            let btnForward = self.navigationItem.leftBarButtonItems?[2] as UIBarButtonItem!
            
            
            if webView.canGoBack || pageCnt > 0 {
                btnBack?.isEnabled = true
            } else {
                btnBack?.isEnabled = false
            }
            if webView.canGoForward{
                btnForward?.isEnabled = true
            } else {
                btnForward?.isEnabled = false
            }
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.navigationItem.title = webView.stringByEvaluatingJavaScript(from: "document.title")
        //        lblTitle.text = webView.stringByEvaluatingJavaScriptFromString("document.title")
        //        lblUrl.text = webView.stringByEvaluatingJavaScriptFromString("document.domain")
        
        if self.navigationItem.leftBarButtonItems?.count > 1 {
            let btnBack = self.navigationItem.leftBarButtonItems?[1] as UIBarButtonItem! //from as? UIBarButtonItem
            let btnForward = self.navigationItem.leftBarButtonItems?[2] as UIBarButtonItem! //from as? UIBarButtonItem
            
            if webView.canGoBack {
                btnBack?.isEnabled = true;
            } else {
                btnBack?.isEnabled = false;
            }
            
            if webView.canGoForward{
                
                btnForward?.isEnabled = true;
            } else {
                btnForward?.isEnabled = false;
            }
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if isPayment {
            let str = request.mainDocumentURL?.URLString
            if (str?.range(of: "checkout/success")) != nil{     //changed from if (let contains = str?.range(of: "checkout/cart"))
                self.dismiss(animated: true, completion: { () -> Void in
                    self.loadSuccessPage()
                })
                
                return false
            } else if (str?.range(of: "checkout/cart")) != nil{
                self.dismiss(animated: true, completion: nil)
                return false
            }
            
            //println(request.mainDocumentURL?.URLString)
        }
        return true
    }
    
    func loadSuccessPage(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CheckoutSuccessController") as! CheckoutSuccessController
        let nav = UINavigationController(rootViewController: vc)
        UIApplication.shared.keyWindow?.topMostController()!.present(nav, animated: true, completion: nil)
        
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MARK: NJ web del
    // ^^^^^^^^^^^^^^^^
    func webViewProgress(_ webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        progressView.setProgress(progress, animated:true)
    }
    
    
    
}
