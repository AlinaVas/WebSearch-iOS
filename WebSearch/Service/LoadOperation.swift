//
//  ImageLoadOperation.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/8/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import Foundation
import Alamofire

class LoadOperation: AsyncOperation {
    var webPage: WebPage
    var response: DataResponse<String>?
    
    init(_ webPage: WebPage) {
        self.webPage = webPage
        super.init()
    }
    
    override func main() {
        
        // check if operation is not cancelled
        if self.isCancelled {
            webPage.status = .unknown
            return
        }
        
        // change status to loading
        webPage.status = .loading
        
        Alamofire.request(webPage.url).responseString { response in
            if self.isCancelled {
                self.webPage.status = .unknown
                return
            }
            
            self.response = response
            self.state = .finished
        }
    }
}
