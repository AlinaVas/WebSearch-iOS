//
//  WebSearchPresenter.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

protocol WebSearchPresenterDelegate: class {
    func reloadTable()
}

class WebSearchPresenter {
    
    weak var viewDelegate: WebSearchPresenterDelegate?
    
    var pagesEnqueued: [WebPage] = []
    
    let startURL = "https://www.twilio.com/blog/2016/08/web-scraping-and-parsing.html-in-swift-with-kanna-and-alamofire.html"
    
    let regexURL = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
    
    let searchString = "Now run the app and"
    
    func searchText() {
        
        Alamofire.request(startURL).responseString { (response) in
            guard let value = response.result.value else { return }
            self.parseHTML(html: value)
        }
    }
    
    func parseHTML(html: String) {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            
            let bodyText = try doc.body()?.text()
            print(bodyText!)
            
            //            if bodyText!.range(of: searchString, options: .caseInsensitive) != nil {
            //                print("Contains!")
            //            } else {
            //                print("dont contain")
            //            }
            
            if bodyText!.localizedCaseInsensitiveContains(searchString) {
                print("Contains!")
            } else {
                print("dont contain")
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
        }
    }
    
}
