//
//  SearchStatus.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

enum SearchStatus {
    case waiting
    case loading
    case found
    case unfound
    case error(String)
}
