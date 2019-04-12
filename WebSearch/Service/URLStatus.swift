//
//  SearchStatus.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

enum URLStatus: CustomStringConvertible {
    case unchecked
    case loading
    case found
    case unfound
    case error(String)
    
    var description: String {
        switch self {
        case .unchecked:
            return ""
        case .loading:
            return "loading"
        case .found:
            return "✅"
        case .unfound:
            return "❌"
        case .error(let msg):
            return "\(msg)"
        }
    }
}
