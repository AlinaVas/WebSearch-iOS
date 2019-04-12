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
    var status: URLStatus
    
    init(url: String, status: URLStatus = .unchecked) {
        self.url = url
        self.status = status
//        super.init()
    }
    
    func changeStatus(to newStatus: URLStatus) {
        self.status = newStatus
    }
    
    static func == (lhs: WebPage, rhs: WebPage) -> Bool {
        return lhs.url == rhs.url
    }
}


