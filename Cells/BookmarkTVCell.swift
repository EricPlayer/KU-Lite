//
//  BookmarkTVCell.swift
//  KU Lite
//
//  Created by Eric on 2019/11/14.
//  Copyright © 2019 ThunPham. All rights reserved.
//

import UIKit

class BookmarkTVCell: UITableViewCell {

    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
