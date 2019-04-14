//
//  SearchStatus.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

// Describe a current status of a URL
//      1) pending - newly added URL
//      2) enqueued - added to a loading operation queue
//      3) loading - loading of URL has started
//      4) found - search string is found
//      5) unfound - search string is not found
//      6) cancelled - loading was cancelled
//      7) error - loading failed with an error

enum URLStatus: CustomStringConvertible, Equatable {
  case pending
  case enqueued
  case loading
  case found
  case unfound
  case cancelled
  case error(String)
  
  var description: String {
    switch self {
    case .pending:
      return ""
    case .enqueued:
      return "enqueued"
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
  
  static func ==(lhs: URLStatus, rhs: URLStatus) -> Bool {
    return lhs.description == rhs.description
  }
}
