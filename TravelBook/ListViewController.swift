//
//  ListViewController.swift
//  TravelBook
//
//  Created by Chris Hand on 8/30/22.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addLocation))
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc
    func addLocation() {
        performSegue(withIdentifier: "toViewController", sender: nil) 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        // this is depreciated. use UIListContentConfiguration
        cell.textLabel?.text = "test"
        return cell
    }
}
