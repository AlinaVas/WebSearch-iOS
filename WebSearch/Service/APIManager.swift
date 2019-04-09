//
//  APIManager.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

class APIManager {
    
    static let shared = APIManager()
    
    private let regexURL = "(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?"
    
    private init() {}

    
    func loadWebPage(url: String, searchString: String, completion: @escaping (WebPage) -> Void)  {
        Alamofire.request(url).responseString { response in
            
            if let error = response.error {
                completion(WebPage(url: url, containedLinks: [], status: .error(error.localizedDescription)))
                return
            }
            
            if let statusCode = response.response?.statusCode, statusCode != 200 {
                completion(WebPage(url: url, containedLinks: [], status: .error("netwotk error: \(statusCode)")))
                return
            }
            
            if let resultValue = response.result.value {
                let (webPageStatus, links) = self.parseHTML(html: resultValue, searchString: searchString)
                completion(WebPage(url: url, containedLinks: links, status: webPageStatus))
            } else {
                completion(WebPage(url: url, containedLinks: [], status: .error("no reault value")))
                return
            }
        }
    }
    
    func parseHTML(html: String, searchString: String) -> (searchStatus: SearchStatus, links: [String]) {
        var webPageStatus: SearchStatus
        var urlsFoundOnPage: [String] = []
        
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let bodyText = try doc.body()?.text()
            print(bodyText!)
            
            // check if web page contains search string
            
            if bodyText!.localizedCaseInsensitiveContains(searchString) {
                print("Contains!")
                webPageStatus = .found
            } else {
                print("dont contain")
                webPageStatus = .unfound
            }
            
            // extracting all url addresses from current web page
            
            urlsFoundOnPage = matches(for: regexURL, in: html)
        
        } catch {
            print(error.localizedDescription)
            webPageStatus = .error(error.localizedDescription)
        }
        print("COUNT: ", urlsFoundOnPage.count)
        return (searchStatus: webPageStatus, links: urlsFoundOnPage)
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        var result: [String] = []
        
        do {
            let type: NSTextCheckingResult.CheckingType = .link
            let detector = try NSDataDetector(types: type.rawValue)
            
            let matches = detector.matches(in: text, options: .reportCompletion, range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches {
                
                guard let range = Range(match.range, in: text) else { continue }
                let url = text[range]
                if url.hasPrefix("https://") || url.hasPrefix("http://") {
                    if url.rangeOfCharacter(from: CharacterSet(charactersIn: " ',><")) == nil {
                        print(url)
                        result.append(String(url))
                    }
                }
                
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return result
        }
        return result
    }
}
