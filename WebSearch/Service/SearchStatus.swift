//
//  SearchStatus.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

enum SearchStatus: CustomStringConvertible {
    case pending
    case loading
    case found
    case unfound
    case error(String)
    
    var description: String {
        switch self {
        case .pending:
            return "in queue ☑︎☒☐"
        case .loading:
            return "loading"
        case .found:
            return "✅"
        case .unfound:
            return "❌"
        case .error(let msg):
            return "error: \(msg)"
        }
    }
}
