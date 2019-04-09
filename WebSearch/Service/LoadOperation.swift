//
//  ImageLoadOperation.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/8/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation

class LoadOperation: AsyncOperation {
    var input: WebPage
    var output: WebPage?
    var searchString: String
    
    init(_ input: WebPage, searchString: String) {
        self.input = input
        self.searchString = searchString
        super.init()
    }
    
    override func main() {
        APIManager.shared.loadWebPage(url: input.url, searchString: searchString) { [unowned self] webPage in
                self.output = webPage
                self.state = .finished
            }
    }
}


// For passing webPage to ChangeStatus Operation

protocol WebPagePass {
    var webPage: WebPage { get }
}

extension LoadOperation: WebPagePass {
    var webPage: WebPage { return output! }
}
