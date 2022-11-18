//
//  DetailsSecondViewController.swift
//  DetoxCamp
//
//  Created by Sezil Akdoğan on 17.11.2022.
//

import UIKit
import CoreData

class DetailsSecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detoxNameTextField: UITextField!
    @IBOutlet weak var ingredientsTextField: UITextField!
    @IBOutlet weak var detoxRecipeTextField: UITextField!
    @IBOutlet weak var saveClicked: UIButton!
    
    var selectedDetoxName = ""
    var selectedDetoxUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedDetoxName != ""{
            saveClicked.isHidden = true
            
            if let uuidString = selectedDetoxUUID?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Detox")
                fetchRequest.predicate = NSPredicate(format: "id = %@" ,uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let results = try context.fetch(fetchRequest)
                    if  results.count > 0 {
                        
                        for result in results as! [NSManagedObject] {
                            
                            if let name = result.value(forKey: "detoxname") as? String {
                                detoxNameTextField.text = name
                            }
                            if let ingredients = result.value(forKey: "ingredients") as? String{
                                ingredientsTextField.text = ingredients
                            }
                            if let recipe = result.value(forKey: "recipe") as? String{
                                detoxRecipeTextField.text = recipe
                            }
                            if let imageData = result.value(forKey: "image") as? Data{
                                let images = UIImage(data: imageData)
                                imageView.image = images
                            }
                            
                        }
                        
                    }
                    
                }catch{
                    print("Hata")
                }
                
            }
            
        }else{
            saveClicked.isHidden = false
            saveClicked.isEnabled = false
            detoxNameTextField.text = ""
            ingredientsTextField.text = ""
            detoxRecipeTextField.text = ""
        }

        // Do any additional setup after loading the view.
        let gestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(closeTheKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageSelect))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
    }
    
    @objc func imageSelect(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveClicked.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func closeTheKeyboard() {
        view.endEditing(true)
        
    }
    
    
    @IBAction func SaveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let detox = NSEntityDescription.insertNewObject(forEntityName: "Detox", into: context)
        detox.setValue(detoxNameTextField.text!, forKey: "detoxname")
        detox.setValue(ingredientsTextField.text!, forKey: "ingredients")
        detox.setValue(detoxRecipeTextField.text!, forKey: "recipe")
        detox.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        detox.setValue(data, forKey: "image")
        
        
        do{
            try context.save()
            
        }catch{
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DataEntered"), object: nil)
        self.navigationController?.popViewController(animated: true)

    }
    
    
}
