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

class Queue<Item: NSObject> {
    
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
}

class WebSearchPresenter {
    
    weak var viewDelegate: WebSearchPresenterDelegate?
    
    var queue = Queue<WebPage>()
    
//    @objc dynamic var operationArray: NSMutableArray = NSMutableArray()
    
//    var observation: NSKeyValueObservation?
    
    var searchString = ""
    

    func isValidInput(searchString: String, startingURL: String, numberOfThreads: String, numberOfURLs: String) -> Bool {
        
        guard let _ = URL(string: startingURL) else {
            viewDelegate?.showAlert(msg: "bad url")
            return false
        }
        queue.addToPending(WebPage(url: startingURL, containedLinks: [], status: .loading))
        viewDelegate?.reloadTable()
        
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
            
            ///temporary kostyl, +1 to make Queue non-generic ///
            // add to loading
            currentWebPage.status = .loading
            queue.loadingItems.append(currentWebPage)
            /////////////////////////////////////////////
            
            let loadOperation = LoadOperation(currentWebPage.url)
            let parseOperation = ParseOperation(searchString: searchString)
            loadOperation.completionBlock = {
                parseOperation.response = loadOperation.response
            }
            parseOperation.completionBlock = { // weak self??
                self.queue.serialOperationQueue.addOperation {
                    
                    // change status of current web page
                    currentWebPage.status = parseOperation.searchStatus!
                    
                    // remove from loading
                    if let index = self.queue.loadingItems.index(of: currentWebPage) {
                        self.queue.loadingItems.remove(at: index)
                    }
                    
                    // add to processed
                    self.queue.addToProcessed(currentWebPage) // does it have a connection with currentWebPage?
                    
                    // add new URLs to pending
                    for url in parseOperation.foundURLs {
                        
                        //check if the limit of checked urls is not exceeded, otherwise break the loop
                        guard !self.queue.isFull() else { break }
                        
                        //check if this url is already in queue, otherwise skip the item
                        guard !self.queue.allItems.contains(where: {$0.url == url}) else { continue }
                        
                        self.queue.addToPending(WebPage(url: url, containedLinks: [], status: .pending))
                    }
                    
                    print("TOOOOOTTAAAALLL: \(self.queue.allItems.count) PENDING \(self.queue.pendingItems.count) LOADING \(self.queue.loadingItems.count)")
                    
                    // update UI
                    OperationQueue.main.addOperation {
                        self.viewDelegate?.reloadTable()
                    }
                    // repeat searching process with new urls
                    self.startSearching()
                }
            }
            parseOperation.addDependency(loadOperation)
            queue.loadOperationQueue.addOperations([loadOperation, parseOperation], waitUntilFinished: false) // or true?
                
//            }
//                let webPage = loadOperation.output!
//
//                self.queue.serialOperationQueue.addOperation {
//
//                    // add loaded url to processed and remove its duplicate from loading
//                    self.queue.loadingItems = self.queue.loadingItems.filter{$0.url != webPage.url}
//                    self.queue.addToProcessed(webPage)
//
//                    // add new urls to queue
//                    for urlString in webPage.containedLinks {
//                        //check if the limit of checked urls is not exceeded, otherwise break the loop
//                        guard !self.queue.isFull() else { break }
//                        //check if this url is already in queue, otherwise skip the item
//                        guard !self.queue.allItems.contains(where: {$0.url == urlString}) else { continue }
//
//                        self.queue.addToPending(WebPage(url: urlString, containedLinks: [], status: .pending))
//                    }
//                    print("TOOOOOTTAAAALLL: \(self.queue.allItems.count) PENDING \(self.queue.pendingItems.count) LOADING \(self.queue.loadingItems.count)")
//
//                    // update UI
//                    OperationQueue.main.addOperation {
//                        self.viewDelegate?.reloadTable()
//                    }
//
//                    // repeat searching process with new urls
//                    // TODO: check if it stops searching when pending is empty
//                    self.startSearching()
////                }
//                }
//            }
//            queue.loadOperationQueue.addOperation(loadOperation)
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
