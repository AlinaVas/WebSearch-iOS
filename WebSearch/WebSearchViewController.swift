//
//  ViewController.swift
//  WebSearch
//
//  Created by Alina FESYK on 4/5/19.
//  Copyright © 2019 Alina FESYK. All rights reserved.
//

import UIKit


class WebSearchViewController: UIViewController {

    @IBOutlet weak var searchStringTextField: UITextField!
    @IBOutlet weak var startingURLTextField: UITextField!
    @IBOutlet weak var numberOfThreadsTextField: UITextField!
    @IBOutlet weak var numberOfURLsTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let presenter = WebSearchPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.viewDelegate = self
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        print("start")
    }
}

extension WebSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension WebSearchViewController: WebSearchPresenterDelegate {
    func reloadTable() {
        tableView.reloadData()
    }
}

