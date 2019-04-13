//
//  SearchStatus.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

enum URLStatus: CustomStringConvertible {
    case pending
    case loading
    case found
    case unfound
    case cancelled
    case error(String)
    
    var description: String {
        switch self {
        case .pending:
            return ""
        case .loading:
            return "loading"
        case .found:
            return "✅"
        case .unfound:
            return "❌"
        case .cancelled:
            return "cancelled"
        case .error(let msg):
            return "\(msg)"
        }
    }
}
