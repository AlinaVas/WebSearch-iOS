//
//  Queue.swift
//  WebSearch
//
//  Created by Alina FESYK on 4/14/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

// MARK: - Class for managing all URL items as a sequence

class Queue {
  
  // concurrent queue for LoadOperations and ParseOperations
  
  let loadOperationQueue = OperationQueue()
  
  // serial queue for accessing shared properties (e.g. array of urls)
  
  let serialOperationQueue = OperationQueue()
  
  // maximum number of URLs that needs to be checked
  
  var maxNumberOfItems: Int = 1
  
  var processedItemsCount = 0
  var pendingItemsCount = 0
  var enqueuedItemsCount = 0
  
  // a sequence of all found urls for processing and displaying
  
  var items: [WebPage] = []
  
  
  // called on "startSearching" to create a new queue
  
  func initiateNewQueue(with items: [WebPage]) {
    self.items = items
    pendingItemsCount += items.count
    processedItemsCount = 0
    enqueuedItemsCount = 0
  }
  
  // adds a new item to a sequence of URLs (items)
  
  func addNewItem(_ item: WebPage) {
    guard items.count < maxNumberOfItems else { return }
    items.append(item)
    pendingItemsCount += 1
  }
  
  
  // returns the first URL with status "pending" from a sequence
  // or nil if one doesn't exist
  
  func getPendingItem() -> WebPage? {
    
    for item in items {
      if item.status == .pending {
        item.status = .enqueued
        enqueuedItemsCount += 1
        pendingItemsCount -= 1
        return item
      }
    }
    return nil
  }
  
  // mark URL as processed and update its status
  
  func updateItemStatus(_ item: WebPage, newStatus: URLStatus) {
    item.status = newStatus
    processedItemsCount += 1
    enqueuedItemsCount -= 1
  }
  
  // returns true if a queue has collected the maximum number of URLs
  
  func isFull() -> Bool {
    return items.count >= maxNumberOfItems
  }
  
  // returns ratio of already processed URLs to the total number that needs to be processed
  
  func getProgress() -> Float {
    return Float(processedItemsCount) / Float(maxNumberOfItems)
  }
}
