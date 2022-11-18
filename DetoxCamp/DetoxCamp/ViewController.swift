//
//  ViewController.swift
//  DetoxCamp
//
//  Created by Sezil Akdoğan on 17.11.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var nameString = [String()]
    var idString = [UUID()]
    var selectedName = ""
    var selectedUUID : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "DataEntered"), object: nil)
    }
    
    
    
    
    @objc func getData(){
        nameString.removeAll(keepingCapacity: false)
        idString.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Detox")
        
        do{
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "detoxname") as? String{
                        nameString.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        idString.append(id)
                    }
                    
            
                }
                
                
                tableView.reloadData()
                
            }
          
            
        }catch{
            print("Hata")
        }
      
        
    }
    
    
    @objc func addButtonClicked(){
        selectedName = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameString.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameString[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsSecondViewController
            destinationVC.selectedDetoxName = selectedName
            destinationVC.selectedDetoxUUID = selectedUUID
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = nameString[indexPath.row]
        selectedUUID = idString[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Detox")
            let uuidString = idString[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "% @" ,uuidString)
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idString[indexPath.row]{
                                context.delete(result)
                                nameString.remove(at: indexPath.row)
                                idString.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                
                                }catch{
                                    
                                }
                                break
                            }
                        }
        
                    }
                    
                }
            }catch{
                print("Hata")
            }
            
            
            
            
            
        }
        
    }


}

