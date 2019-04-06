//
//  WebPage.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

struct WebPage {
    var url: String
    var containedWebPages: [WebPage] = []
    var status: SearchStatus
}


