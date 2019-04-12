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

class ParseOperation: Operation {
    let searchString: String
    var response: DataResponse<String>?
    var statusOfURL: URLStatus = .unknown
    var foundURLs: [String] = []
    var stopParsingURLs: Bool = false
    
    init(searchString: String) {
        self.searchString = searchString
    }
    
    override func main() {
        if self.isCancelled { return }
        
        // check if error is present
        if let error = response?.error {
            statusOfURL = .error(error.localizedDescription)
            return
        }
        
        // check if status is 'OK'
        if let statusCode = response?.response?.statusCode, statusCode != 200 {
            statusOfURL = .error("netwotk error: \(statusCode)")
            return
        }
        
        // check if content-type is appropriate
        if let contentType = response?.response?.mimeType, contentType.hasPrefix("text") == false {
            statusOfURL = .error("error: url's content-type is \(contentType)")
            return
        }
        
        // maek sure the result value is present
        guard let html = response?.result.value else {
            statusOfURL = .error("network error: no result value")
            return
        }

        
        // Parse HTML response from URL
        
        do {

            let doc: Document = try SwiftSoup.parse(html)
            let bodyText = try doc.body()?.text()

            // check if web page contains search string
            
            if bodyText!.localizedCaseInsensitiveContains(searchString) {
                statusOfURL = .found
            } else {
                statusOfURL = .unfound
            }
            
            
            // extracting all URLs from current web page
            
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
            print(error.localizedDescription)
            statusOfURL = .error(error.localizedDescription)
        }

    }
    
}
