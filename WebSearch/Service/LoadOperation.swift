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
    var url: String
    var response: DataResponse<String>?
    
    init(_ url: String) {
        self.url = url
        super.init()
    }
    
    override func main() {
        if self.isCancelled { return }
//        APIManager.shared.loadWebPage(url: input.url, searchString: searchString) { [unowned self] webPage in
//            self.output = webPage
//            self.state = .finished
//        }
        
        Alamofire.request(url).responseString { response in
            if self.isCancelled { return }
            
            self.response = response
            self.state = .finished
        }
    }
}



// For passing webPage to ChangeStatus Operation

//protocol WebPagePass {
//    var webPage: WebPage { get }
//}
//
//extension LoadOperation: WebPagePass {
//    var webPage: WebPage { return output! }
//}

