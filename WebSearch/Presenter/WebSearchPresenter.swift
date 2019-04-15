//
//  WebSearchPresenter.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

// MARK: - Protocol for a view delegate (UI updates)

protocol WebSearchPresenterDelegate: class {
  func reloadTable()
  func showAlert(msg: String)
  func updateProgressBar(with newValue: Float)
}


// MARK: - Presenter for a view delegate (UI updates)

class WebSearchPresenter {
  weak var viewDelegate: WebSearchPresenterDelegate?
  
  // queue for storing a sequence of URLs
  
  private var queue = Queue()
  
  private var searchString = ""
  private var startingURL = ""
  
  // status and progress of searching process
  
  private var searchStatus: SearchStatus = .inactive
  private var searchProgress: Float = 0 {
    didSet {
      OperationQueue.main.addOperation {
        self.viewDelegate?.updateProgressBar(with: self.searchProgress)
      }
    }
  }
  
  
  // check if user input is valid
  
  func isValidInput(searchString: String, startingURL: String, numberOfThreads: String, numberOfURLs: String) -> Bool {
    
    // check if "search string" and "starting URL" inputs are present
    
    guard searchString.trimmingCharacters(in: .whitespaces) != "",
      startingURL.trimmingCharacters(in: .whitespaces) != "" else {
        viewDelegate?.showAlert(msg: "Enter a URL and a search string!")
        return false
    }
    self.searchString = searchString
    
    // check if starting URL has a good format
    
    guard let _ = URL(string: startingURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
      viewDelegate?.showAlert(msg: "Bad url")
      return false
    }
    self.startingURL = startingURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    
    
    // check input for number of threads
    
    if let numberOfThreads = Int(numberOfThreads), numberOfThreads > 0 {
      queue.loadOperationQueue.maxConcurrentOperationCount = numberOfThreads
    } else if numberOfThreads.trimmingCharacters(in: .whitespaces) == "" {
      queue.loadOperationQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
    } else {
      viewDelegate?.showAlert(msg: "Invalid number of threads")
      return false
    }
    
    // check input for number of URLs
    
    if let numberOfURLs = Int(numberOfURLs), numberOfURLs > 0  {
      queue.maxNumberOfItems = numberOfURLs
    } else if numberOfURLs.trimmingCharacters(in: .whitespaces) == "" {
      queue.maxNumberOfItems = 1
    } else {
      viewDelegate?.showAlert(msg: "Invalid number of URLs")
      return false
    }
    
    queue.loadOperationQueue.qualityOfService = .utility
    queue.serialOperationQueue.qualityOfService = .utility
    queue.serialOperationQueue.maxConcurrentOperationCount = 1
    
    return true
  }
  
  
  // Add loading operations for new URLs to a queue
  
  private func loadPendingURLs() {
    
    // stop searching process if all found URLs are processed
    
    if queue.pendingItemsCount == 0 && queue.enqueuedItemsCount == 0 {
      stopSearching()
      return
    }
    
    // iterate over all pending URLs
    
    while let currentWebPage = queue.getPendingItem() {
      
      let loadOperation = LoadOperation(currentWebPage)
      let parseOperation = ParseOperation(searchString: searchString)
      
      // pass network response to parseOperation after loadingOperation is finished
      
      loadOperation.completionBlock = {
        if loadOperation.isCancelled { return }
        parseOperation.response = loadOperation.response
        parseOperation.stopParsingURLs = self.queue.isFull()
      }
      
      // handle output of parseOperation
      
      parseOperation.completionBlock = {
        self.queue.serialOperationQueue.addOperation {
          if parseOperation.isCancelled { return }
          
          // change status of a processed web page
          
          self.queue.updateItemStatus(currentWebPage, newStatus: parseOperation.statusOfURL)
          self.searchProgress = self.queue.getProgress()
          
          // add newly found URLs to a sequence for future processing
          
          for url in parseOperation.foundURLs {
            
            // check if the limit of checked urls is not exceeded, otherwise break the loop
            
            guard !self.queue.isFull() else { break }
            
            // check if a URL is already in queue, otherwise skip the item
            
            guard !self.queue.items.contains(where: {$0.url == url}) else { continue }
            
            // add URL
        
            self.queue.addNewItem(WebPage(url: url, index: self.queue.items.count))
            
          }
          
          // update UI
          
          OperationQueue.main.addOperation {
            self.viewDelegate?.reloadTable()
          }
          
          // repeat searching process with new URLs
          
          self.loadPendingURLs()
        }
      }
      parseOperation.addDependency(loadOperation)
      queue.loadOperationQueue.addOperations([loadOperation, parseOperation], waitUntilFinished: false)
    }
  }
  
  // start or resume searching process
  
  func startSearching() {
    if searchStatus == .active { return }
    
    print("▶️▶️▶️ STARTED ▶️▶️▶️")
    if searchStatus == .inactive {
      queue.initiateNewQueue(with: [WebPage(url: startingURL, index: queue.items.count)])
      viewDelegate?.reloadTable()
      searchProgress = 0
    }
    if queue.loadOperationQueue.isSuspended == true {
      queue.loadOperationQueue.isSuspended = false
      queue.serialOperationQueue.isSuspended = false
    }
    searchStatus = .active
    queue.serialOperationQueue.addOperation {
      self.loadPendingURLs()
    }
  }
  
  
  // pause searching process
  
  func pauseSearching() {
    if searchStatus == .active {
      print("⏸⏸⏸ PAUSED ⏸⏸⏸")
      queue.loadOperationQueue.isSuspended = true
      queue.serialOperationQueue.isSuspended = true
      searchStatus = .paused
    }
  }
  
  
  // stop searching process
  
  func stopSearching() {
    if searchStatus == .active || searchStatus == .paused {
      print("⏹⏹⏹ STOPPED ⏹⏹⏹")
      queue.loadOperationQueue.cancelAllOperations()
      queue.serialOperationQueue.cancelAllOperations()
      searchStatus = .inactive
      searchProgress = 1
    }
  }
}

// MARK: - Methods for UITableViewDataSource

extension WebSearchPresenter {
  
  func getNumberOfRows() -> Int {
    return queue.items.count
  }
  
  func getCellContent(at index: Int) -> (url: String, status: String) {
    return (url: queue.items[index].url, status: queue.items[index].status.description)
  }
}
