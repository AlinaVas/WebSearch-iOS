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
    @IBOutlet weak var progressBar: UIProgressView!
    
    let presenter = WebSearchPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        presenter.viewDelegate = self
    }
    
    func setView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        progressBar.progress = 0
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        presenter.stopSearching()
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        presenter.pauseSearching()
    }
    
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        // check if there's input in textFields
        
        if presenter.isValidInput(searchString: searchStringTextField.text!, startingURL: startingURLTextField.text!, numberOfThreads: numberOfThreadsTextField.text!, numberOfURLs: numberOfURLsTextField.text!) {
            presenter.startSearching()
        }
        
    }
}

extension WebSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebPageTableViewCell", for: indexPath) as! WebPageTableViewCell
        let (url, status) = presenter.getCellContent(at: indexPath.row)
        cell.addressLabel.text = url
        cell.statusLabel.text = status
        return cell
    }
}

extension WebSearchViewController: WebSearchPresenterDelegate {
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    func updateProgressBar(with newValue: Float) {
        UIView.animate(withDuration: 1) {
            self.progressBar.setProgress(newValue, animated: true)
        }
    }
    
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Oops!", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

//TODO: Textfield should return

