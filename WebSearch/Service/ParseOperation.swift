//
//  ParseOperation.swift
//  WebSearch
//
//  Created by Alina FESYK on 4/10/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

// MARK: - Operation for parsing network response from a URL:
//                     1) check the occurrence of a search string
//                     2) fetch all the URLs on a web-page

class ParseOperation: Operation {
  
  let searchString: String
  var response: DataResponse<String>?
  var statusOfURL: URLStatus = .cancelled
  var foundURLs: [String] = []
  var stopParsingURLs: Bool = false
  
  init(searchString: String) {
    self.searchString = searchString
  }
  
  override func main() {
    if self.isCancelled {
      statusOfURL = .cancelled
      return
    }
    
    // check if error is present
    
    if let error = response?.error {
      statusOfURL = .error(error.localizedDescription)
      return
    }
    
    // check if status code is 'OK'
    
    if let statusCode = response?.response?.statusCode, statusCode != 200 {
      statusOfURL = .error("netwotk error: \(statusCode)")
      return
    }
    
    // check if content-type is appropriate
    
    if let contentType = response?.response?.mimeType, contentType.hasPrefix("text") == false {
      statusOfURL = .error("url's content-type is \(contentType)")
      return
    }
    
    // make sure the result value is present
    
    guard let html = response?.result.value else {
      statusOfURL = .error("network error: no data returned from a URL")
      return
    }
    
    
    if self.isCancelled {
      statusOfURL = .cancelled
      return
    }
    
    
    
    // Parse HTML response from a URL
    
    do {
      
      let doc: Document = try SwiftSoup.parse(html)
      let bodyText = try doc.body()?.text()
      
      // check if text of current web page contains a search string
      
      if bodyText!.localizedCaseInsensitiveContains(searchString) {
        statusOfURL = .found
      } else {
        statusOfURL = .unfound
      }
      
      // extract all URLs from current web page
      
      if stopParsingURLs == true { return }
      let linkElements = try doc.select("a")
      
      for element in linkElements {
        var href = try element.attr("href")
        if (href.hasPrefix("http://") || href.hasPrefix("https://")) && !foundURLs.contains(href) {
          if href.hasSuffix("/") {
            href = String(href.dropLast())
          }
          foundURLs.append(href)
        }
      }
      
    } catch {
      statusOfURL = .error(error.localizedDescription)
    }
    
  }
  
}
