//
//  BookmarkModel.swift
//  KU Lite
//
//  Created by Eric on 2019/11/14.
//  Copyright © 2019 ThunPham. All rights reserved.
//

import Foundation

class BookmarkModel {
    private var id = 0
    private var title = ""
    private var url = ""
    
    init() {
        self.id = 0
        self.title = ""
        self.url = ""
    }
    
    init(id: Int, title: String, url: String) {
        self.id = id
        self.title = title
        self.url = url
    }
    
    public func getId() -> Int {
        return id
    }
    
    public func getTitle() -> String {
        return title
    }
    
    public func getUrl() -> String {
        return url
    }
}
