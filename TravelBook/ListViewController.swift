//
//  ListViewController.swift
//  TravelBook
//
//  Created by Chris Hand on 8/30/22.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var idArray = [UUID]()
    var nameArray = [String]()
    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addLocation))
        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }
    
    @objc
    func addLocation() {
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        // this is depreciated. use UIListContentConfiguration
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            nameArray.removeAll()
            idArray.removeAll()
            
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    nameArray.append(name)
                }
                
                let id = result.value(forKey: "id") as! UUID
                idArray.append(id)
                
            }
            
            tableView.reloadData()
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
