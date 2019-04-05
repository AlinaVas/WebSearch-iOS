//
//  ViewController.swift
//  WebSearch
//
//  Created by Alina FESYK on 4/5/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    let startURL = "https://www.twilio.com/blog/2016/08/web-scraping-and-parsing.html-in-swift-with-kanna-and-alamofire.html"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchText()
    }
    
    
    func searchText() {
        
        
        Alamofire.request(startURL).responseString { (response) in
            print(response.result.value!)
        }
    }



}

