//
//  IQTitleBarButtonItem.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-15 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit

class IQTitleBarButtonItem: UIBarButtonItem {
   
    var font : UIFont? {
    
        didSet {
            if let unwrappedFont = font {
                _titleLabel?.font = unwrappedFont
            } else {
                _titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            }
        }
    }
    
    fileprivate var _titleLabel : UILabel?
    fileprivate var _titleView : UIView?

    override init() {
        super.init()
    }
    
    init(frame : CGRect, title : String?) {

        super.init(title: nil, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        _titleView = UIView(frame: frame)
        _titleView?.backgroundColor = UIColor.clear
        _titleView?.autoresizingMask = .flexibleWidth
        
        _titleLabel = UILabel(frame: _titleView!.bounds)
        _titleLabel?.textColor = UIColor.lightGray
        _titleLabel?.backgroundColor = UIColor.clear
        _titleLabel?.textAlignment = .center
        _titleLabel?.text = title
        _titleLabel?.autoresizingMask = .flexibleWidth
        font = UIFont.boldSystemFont(ofSize: 12.0)
        _titleLabel?.font = self.font
        customView = _titleLabel
        isEnabled = false
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
