//
//  WebPage.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

class WebPage {
  var url: String
  var status: URLStatus
  var index: Int
  
  init(url: String, status: URLStatus = .pending, index: Int) {
    self.url = url
    self.status = status
    self.index = index
  }
  
  static func == (lhs: WebPage, rhs: WebPage) -> Bool {
    return lhs.url == rhs.url
  }
}


