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
    
    let startURL = "https://www.twilio.com/blog/2016/08/web-scraping-and-parsing.html-in-swift-with-kanna-and-alamofire.html"
    
    private let regexURL = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
    
//    let searchString = "Now run the app and"
    
    private init() {}

    
    func loadWebPage(url: String, searchString: String, completion: @escaping (Result<WebPage, CustomError>) -> Void)  {
        Alamofire.request(startURL).responseString { response in
            
            if let error = response.error {
                completion(.failure(.custom(error.localizedDescription)))
//                self.viewDelegate?.showAlert(msg: error.localizedDescription)
                return
            }
            
            if let statusCode = response.response?.statusCode, statusCode != 200 {
                completion(.failure(.networkError(statusCode)))
//                self.viewDelegate?.showAlert(msg: "Network error: \(response.response?.statusCode ?? 0)")
                return
            }
            
            if let resultValue = response.result.value {
//                completion(.success(resultValue))
                let (webPageStatus, links) = self.parseHTML(html: resultValue, searchString: searchString)
                completion(.success(WebPage(url: url, containedLinks: links, status: webPageStatus)))
            } else {
                completion(.failure(.custom("no result value")))
//                self.viewDelegate?.showAlert(msg: "Network error: no result value")
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
            
            if bodyText!.localizedCaseInsensitiveContains(searchString) {
                print("Contains!")
                webPageStatus = .found
            } else {
                print("dont contain")
                webPageStatus = .unfound
            }
            
            //            if let elementsMatchingSearchString = try doc.body()?.getElementsContainingText(searchString) {
            //                print("matches found: \(elementsMatchingSearchString.array().count)")
            //
            //                for element in elementsMatchingSearchString.array() {
            //                    print(try element.text())
            //                }
            //            }
            
            
            
            //            let linkElements: Elements = try doc.select("a[href]")
            //
            //            for link in linkElements {
            //                print(try link.attr("href"))
            //            }
            
        } catch {
            print(error.localizedDescription)
            webPageStatus = .error(error.localizedDescription)
        }
        
        return (searchStatus: webPageStatus, links: urlsFoundOnPage)
    }
}
