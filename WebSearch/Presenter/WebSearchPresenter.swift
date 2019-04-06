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
    func showAlert(msg: String)
}

class WebSearchPresenter {
    
    weak var viewDelegate: WebSearchPresenterDelegate?
    
    var enqueuedPages: [WebPage] = [] {
        didSet {
            viewDelegate?.reloadTable()
        }
    }
    
    var numberOfThreads: Int?
    var numberOfURLs: Int?
    
    
    func validateInputParameters(startingURL: String, numberOfThreads: String, numberOfURLs: String) {
        
        guard let _ = URL(string: startingURL) else {
            viewDelegate?.showAlert(msg: "bad url")
            return
        }
        
        guard let numOfThreads = Int(numberOfThreads), numOfThreads > 0 else {
            viewDelegate?.showAlert(msg: "invalid number of threads")
            return
        }
        
        guard let numberOfURLs = Int(numberOfURLs), numberOfURLs > 0 else {
            viewDelegate?.showAlert(msg: "invalid number of threads")
            return
        }
    }
    
    func startSearching(string: String, startingURL: String, numberOfThreads: String, numberOfURLs: String) {
        
        validateInputParameters(startingURL: startingURL, numberOfThreads: numberOfThreads, numberOfURLs: numberOfURLs)
        
//        APIManager.shared.loadWebPage(url: startingURL, searchString: string) { result in
//            switch result {
//                case .failure(<#T##Failure#>)
//            }
//        }

    }

    
}

extension WebSearchPresenter {
    
    func getNumberOfRows() -> Int {
        return enqueuedPages.count
    }
    
    func getCellContent(at index: Int) -> (url: String, status: String) {
        return (url: enqueuedPages[index].url, status: enqueuedPages[index].status.description)
    }
}
