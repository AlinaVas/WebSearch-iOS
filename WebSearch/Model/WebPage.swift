//
//  WebPage.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

class WebPage: NSObject {
    var url: String
//    var containedLinks: [String] = []
    var status: SearchStatus
    
    init(url: String, containedLinks: [String] = [], status: SearchStatus = .pending) {
        self.url = url
//        self.containedLinks = containedLinks
        self.status = status
        super.init()
    }
    
    func changeStatus(to newStatus: SearchStatus) {
        self.status = newStatus
    }
    
    static func == (lhs: WebPage, rhs: WebPage) -> Bool {
        return lhs.url == rhs.url
    }
}


