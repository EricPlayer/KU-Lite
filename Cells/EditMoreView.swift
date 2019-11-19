//
//  EditMoreView.swift
//  WebBrowser
//
//  Created by Eric on 2019/11/6.
//  Copyright © 2019 Legolas. All rights reserved.
//

import UIKit

class EditMoreView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var homeUrlTxt: UITextField!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var incognitoToggle: UISwitch!
    @IBOutlet weak var bookmarksButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("EditMoreView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
    }
}
