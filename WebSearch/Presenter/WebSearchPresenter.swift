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
    func updateProgressBar(with newValue: Float)
}

class Queue<Item: NSObject> {
    
    // concurrent queue for URL-requests
    let loadOperationQueue = OperationQueue()
    
    // serial operation queue for accessing shared properties
    let serialOperationQueue = OperationQueue()
    
    // maximum number of URLs that need to be checked ultimately
    var maxNumberOfItems: Int = 1
    
    var pendingItems: [Item] = []       // newly added URLs
    var loadingItems: [Item] = []       // loading URLs
    var processedItems: [Item] = []     // URLs that were checked
    
    // all URLs for tableView dataSource
    var allItems: [Item] {
        return processedItems + loadingItems + pendingItems
    }
    
    func initiateNewQueue(with items: [Item]) {
        pendingItems = items
        loadingItems = []
        processedItems = []
    }
    
    func addToPending(_ item: Item) {
        guard allItems.count < maxNumberOfItems else {return}
        pendingItems.append(item)
    }
    
    func removeFromPending() -> Item? {
        guard !self.pendingItems.isEmpty else { return nil }
        let item = pendingItems.removeFirst()
//        loadingItems.append(item)
        return item
    }
    
    func addToProcessed(_ item: Item) {
        // is it really filtered?
        loadingItems = loadingItems.filter{$0 !== item}
        processedItems.append(item)

    }
    
    func isFull() -> Bool {
        return allItems.count >= maxNumberOfItems
    }
    
    func getProgress() -> Float {
        return Float(processedItems.count) / Float(maxNumberOfItems)
    }
}

class WebSearchPresenter {
    
    weak var viewDelegate: WebSearchPresenterDelegate?
    
    var queue = Queue<WebPage>()
    
    var searchString = ""
    
    var startingURL = ""
    
    var searchStatus: SearchStatus = .inactive

    var searchProgress: Float = 0 {
        didSet {
            OperationQueue.main.addOperation {
                self.viewDelegate?.updateProgressBar(with: self.searchProgress)
            }
        }
    }
    

    func isValidInput(searchString: String, startingURL: String, numberOfThreads: String, numberOfURLs: String) -> Bool {
        
        guard searchString.trimmingCharacters(in: .whitespaces) != "",
            startingURL.trimmingCharacters(in: .whitespaces) != "" else {
                viewDelegate?.showAlert(msg: "Enter a URL and a search string!")
                return false
        }
        self.searchString = searchString
        
        
        guard let _ = URL(string: startingURL) else {
            viewDelegate?.showAlert(msg: "Bad url")
            return false
        }
        self.startingURL = startingURL
        
        
        if let numberOfThreads = Int(numberOfThreads), numberOfThreads > 0 {
            queue.loadOperationQueue.maxConcurrentOperationCount = numberOfThreads
        } else if numberOfThreads.trimmingCharacters(in: .whitespaces) == "" {
            queue.loadOperationQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        } else {
            viewDelegate?.showAlert(msg: "Invalid number of threads")
            return false
        }
        
        
        if let numberOfURLs = Int(numberOfURLs), numberOfURLs > 0  {
            queue.maxNumberOfItems = numberOfURLs
        } else if numberOfURLs.trimmingCharacters(in: .whitespaces) == "" {
            queue.maxNumberOfItems = 1
        } else {
            viewDelegate?.showAlert(msg: "Invalid number of URLs")
            return false
        }
        
        queue.serialOperationQueue.qualityOfService = .utility
        queue.loadOperationQueue.qualityOfService = .utility
        queue.serialOperationQueue.maxConcurrentOperationCount = 1
        
        return true
    }
    
    fileprivate func loadPendingURLs() {
        
        // stop searching process if all found URLs are processed
        
        if queue.pendingItems.isEmpty && queue.loadingItems.isEmpty {
            stopSearching()
            return
        }
        
        // iterate over all pending URLs
        
        while let currentWebPage = queue.removeFromPending() {
            
            ///temporary kostyl, +1 to make Queue non-generic ///
            // add to loading
            currentWebPage.status = .loading
            queue.loadingItems.append(currentWebPage)
            /////////////////////////////////////////////
            
            let loadOperation = LoadOperation(currentWebPage.url)
            let parseOperation = ParseOperation(searchString: searchString)
            loadOperation.completionBlock = {
                parseOperation.response = loadOperation.response
                parseOperation.stopParsingURLs = self.queue.isFull()
            }
            parseOperation.completionBlock = {                 // weak self??
                self.queue.serialOperationQueue.addOperation {
                    
                    // change status of current web page
                    currentWebPage.status = parseOperation.statusOfURL
                    
                    // remove from loading
                    if let index = self.queue.loadingItems.index(of: currentWebPage) {
                        self.queue.loadingItems.remove(at: index)
                    }
                    
                    // add to processed
                    self.queue.addToProcessed(currentWebPage)
                    self.searchProgress = self.queue.getProgress()

                    
                    // add new URLs to pending
                    for url in parseOperation.foundURLs {
                        
                        //check if the limit of checked urls is not exceeded, otherwise break the loop
                        guard !self.queue.isFull() else { break }
                        
                        //check if this url is already in queue, otherwise skip the item
                        guard !self.queue.allItems.contains(where: {$0.url == url}) else { continue }
                        
                        self.queue.addToPending(WebPage(url: url, status: .unchecked))
                    }
                    
                    print("TOOOOOTTAAAALLL: \(self.queue.allItems.count) PENDING \(self.queue.pendingItems.count) LOADING \(self.queue.loadingItems.count) PROCESSED: \(self.queue.processedItems.count)")
                    
                    // update UI
                    OperationQueue.main.addOperation {
                        self.viewDelegate?.reloadTable()
                    }
                    // repeat searching process with new urls
                    self.loadPendingURLs()
                }
            }
            parseOperation.addDependency(loadOperation)
            queue.loadOperationQueue.addOperations([loadOperation, parseOperation], waitUntilFinished: false) // or true?
        }
    }
    
    func startSearching() {
        if searchStatus == .active { return }
        
        if searchStatus == .inactive {
            print("STARTED👹")
            queue.initiateNewQueue(with: [WebPage(url: startingURL)])
            viewDelegate?.reloadTable()
        }
        queue.loadOperationQueue.isSuspended = false
        searchStatus = .active
        loadPendingURLs()
    }
    
    func pauseSearching() {
        if searchStatus == .active {
            print("PAUSED!🍔")
            queue.loadOperationQueue.isSuspended = true
            searchStatus = .paused
        }
    }
    
    func stopSearching() {
        if searchStatus == .active || searchStatus == .paused {
            print("STOPPED🤪")
            queue.loadOperationQueue.cancelAllOperations()
            queue.loadOperationQueue.isSuspended = true
            searchStatus = .inactive
        }
    }
}

extension WebSearchPresenter {
    
    func getNumberOfRows() -> Int {
        return queue.allItems.underestimatedCount
    }
    
    func getCellContent(at index: Int) -> (url: String, status: String) {
        return (url: queue.allItems[index].url, status: queue.allItems[index].status.description)
    }
}
