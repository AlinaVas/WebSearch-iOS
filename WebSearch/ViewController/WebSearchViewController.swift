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
        
        setView()
        presenter.viewDelegate = self
    }
    
    func setView() {
        
        searchStringTextField.layer.borderWidth = 1
        searchStringTextField.layer.cornerRadius = 5
        searchStringTextField.layer.borderColor = UIColor.lightText.cgColor
        
        startingURLTextField.layer.borderWidth = 1
        startingURLTextField.layer.cornerRadius = 5
        startingURLTextField.layer.borderColor = UIColor.lightText.cgColor
        
        numberOfThreadsTextField.layer.borderWidth = 1
        numberOfThreadsTextField.layer.cornerRadius = 5
        numberOfThreadsTextField.layer.borderColor = UIColor.lightText.cgColor
        
        numberOfURLsTextField.layer.borderWidth = 1
        numberOfURLsTextField.layer.cornerRadius = 5
        numberOfURLsTextField.layer.borderColor = UIColor.lightText.cgColor
        
        
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        searchStringTextField.layer.borderColor = (searchStringTextField.text! != "") ? UIColor.lightText.cgColor : UIColor.red.cgColor
        startingURLTextField.layer.borderColor = (startingURLTextField.text! != "") ? UIColor.lightText.cgColor : UIColor.red.cgColor
        numberOfThreadsTextField.layer.borderColor = (numberOfThreadsTextField.text! != "") ? UIColor.lightText.cgColor : UIColor.red.cgColor
        numberOfURLsTextField.layer.borderColor = (numberOfURLsTextField.text! != "") ? UIColor.lightText.cgColor : UIColor.red.cgColor
        
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
        print(url, status)
        cell.addressLabel.text = url
        cell.statusLabel.text = status
        return cell
    }
}

extension WebSearchViewController: WebSearchPresenterDelegate {
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Oops!", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

//TODO: Textfield should return

