//
//  WebSearchPresenter.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

protocol WebSearchPresenterDelegate: class {
    func reloadTable()
    func showAlert(msg: String)
}

class Queue<Item: Equatable> {
    
    // concurrent queue for URL-requests
    let loadOperationQueue = OperationQueue()
    
    // serial operation queue for accessing shared properties
    let serialOperationQueue = OperationQueue()
    
    // maximum number of URLs that need to be checked ultimately
    var maxNumberOfItems: Int = 1
    
    var pendingItems: [Item] = []   // newly added URLs
    var loadingItems: [Item] = []   // loading URLs
    var processedItems: [Item] = [] // URLs that were checked
    
    // all URLs for tableView dataSource
    var allItems: [Item] {
        return processedItems + loadingItems + pendingItems
    }
    
    func addToPending(_ item: Item) {
        guard allItems.count < maxNumberOfItems else {return}
        pendingItems.append(item)
    }
    
    func removeFromPending() -> Item? {
        guard !self.pendingItems.isEmpty else { return nil }
        let item = pendingItems.removeFirst()
        loadingItems.append(item)
        return item
    }
    
    func addToProcessed(_ item: Item) {
        loadingItems = loadingItems.filter{$0 != item}
        processedItems.append(item)

    }
    
    func isFull() -> Bool {
        return allItems.count >= maxNumberOfItems
    }
}

class WebSearchPresenter {
    
    weak var viewDelegate: WebSearchPresenterDelegate?
    
    var queue = Queue<WebPage>()
    
    @objc dynamic var operationArray: NSMutableArray = NSMutableArray()
    
    var observation: NSKeyValueObservation?
    
    var searchString = ""
    

    func isValidInput(searchString: String, startingURL: String, numberOfThreads: String, numberOfURLs: String) -> Bool {
        
        guard let _ = URL(string: startingURL) else {
            viewDelegate?.showAlert(msg: "bad url")
            return false
        }
        queue.addToPending(WebPage(url: startingURL, containedLinks: [], status: .pending))
        
        guard let numberOfThreads = Int(numberOfThreads), numberOfThreads > 0 else {
            viewDelegate?.showAlert(msg: "invalid number of threads")
            return false
        }
        queue.loadOperationQueue.maxConcurrentOperationCount = numberOfThreads
        
        guard let numberOfURLs = Int(numberOfURLs), numberOfURLs > 0 else {
            viewDelegate?.showAlert(msg: "invalid number of URLs")
            return false
        }
        queue.maxNumberOfItems = numberOfURLs
        
        queue.serialOperationQueue.qualityOfService = .utility
        queue.loadOperationQueue.qualityOfService = .utility
        queue.serialOperationQueue.maxConcurrentOperationCount = 1
        self.searchString = searchString
        
        return true
    }
    
    func startSearching() {
        
        while let currentWebPage = queue.removeFromPending() {
            let loadOperation = LoadOperation(currentWebPage, searchString: searchString)
            
            loadOperation.completionBlock = {
                let webPage = loadOperation.output!
                
                self.queue.serialOperationQueue.addOperation {
                    
                    // add loaded url to processed
                    self.queue.addToProcessed(webPage)
                    
                    // add new urls to queue
                    for urlString in webPage.containedLinks {
                        //check if the limit of checked urls is not exceeded
                        guard !self.queue.isFull() else { return }
                        //check if this url is already in queue
                        guard !self.queue.allItems.contains(where: {$0.url == urlString}) else { continue }
                        
                        self.queue.addToPending(WebPage(url: urlString, containedLinks: [], status: .pending))
                    }
                    
                    // update UI
                    OperationQueue.main.addOperation {
                        self.viewDelegate?.reloadTable()
                    }
                    
                    // repeat searching process with new urls
                    self.startSearching()
                }
            }
            queue.loadOperationQueue.addOperation(loadOperation)
        }
        
    }
}

extension WebSearchPresenter {
    
    func getNumberOfRows() -> Int {
        return queue.allItems.count
    }
    
    func getCellContent(at index: Int) -> (url: String, status: String) {
        return (url: queue.allItems[index].url, status: queue.allItems[index].status.description)
    }
}
