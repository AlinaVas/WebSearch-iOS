//
//  WebPageTableViewCell.swift
//  WebSearch
//
//  Created by Alina Fesyk on 4/6/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import UIKit

class WebPageTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel! {
        willSet {
            if newValue.text!.hasPrefix("error") {
                newValue.textColor = UIColor.red
            } else {
                newValue.textColor = UIColor.gray
            }
            setNeedsLayout()
        }
    }
    
}
