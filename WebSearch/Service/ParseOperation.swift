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
    var searchStatus: SearchStatus?
    var foundURLs: [String] = []
    
    init(searchString: String) {
        self.searchString = searchString
    }
    
    override func main() {
        if self.isCancelled { return }
        
        
        if let error = response?.error {
            searchStatus = .error(error.localizedDescription)
            return
        }
        
        if let statusCode = response?.response?.statusCode, statusCode != 200 {
            searchStatus = .error("netwotk error: \(statusCode)")
            return
        }
        
        // TODO: when img url?
        
        guard let html = response?.result.value else {
            searchStatus = .error("network error: no result value")
            return
        }

        
        // Parse HTML response from URL
        
        do {
            if Thread.isMainThread {
                print("😇")
            }
            let doc: Document = try SwiftSoup.parse(html)
            let bodyText = try doc.body()?.text()
            print(bodyText!)
            
            // check if web page contains search string
            
            if bodyText!.localizedCaseInsensitiveContains(searchString) {
                print("Contains!")
                searchStatus = .found
            } else {
                print("dont contain")
                searchStatus = .unfound
            }
            
            // extracting all URLs from current web page
            
            let linkElements = try doc.select("a")
            
            for element in linkElements {
                var href = try element.attr("href")
                if (href.hasPrefix("http://") || href.hasPrefix("https://")) && !foundURLs.contains(href) {
                    if href.hasSuffix("/") {
                        href = String(href.dropLast())
                    }
                    print(href)
                    foundURLs.append(href)
                }
            }
            
        } catch {
            print(error.localizedDescription)
            searchStatus = .error(error.localizedDescription)
        }

    }
    
}
