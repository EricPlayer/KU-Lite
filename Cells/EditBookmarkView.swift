//
//  EditBookmarkView.swift
//  KU Lite
//
//  Created by Eric on 2019/11/14.
//  Copyright © 2019 ThunPham. All rights reserved.
//

import UIKit

class EditBookmarkView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var bookmarkTxt: UITextField!
    @IBOutlet weak var urlTxt: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("EditBookmarkView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
    }
}
