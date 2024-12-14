//
//  createCustomerViewController.swift
//  StitchSmart Pro
//
//  Created by Unique Consulting Firm on 11/12/2024.
//

import UIKit

class createCustomerViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var contactTf: UITextField!
    @IBOutlet weak var addressTf: UITextField!
    @IBOutlet weak var gender: DropDown!
    @IBOutlet weak var other: UITextField!
    
    var datasource = [DataSource]()
    var selectedRceord: DataSource?
    var ID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        gender.delegate = self
        gender.optionArray = ["Male","Female","Other"]
        gender.didSelect { (selectedText, index, id) in
        self.gender.text = selectedText
            
        }
        
        if !(ID.isEmpty)
        {
            nameTF.text = selectedRceord?.Name
            contactTf.text = selectedRceord?.contact
            addressTf.text = selectedRceord?.address
            gender.text = selectedRceord?.gender
            other.text = selectedRceord?.other
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func hideKeyboard()
    {
       view.endEditing(true)
    }
    
    
     func saveData()
    {
        guard let name = nameTF.text, !name.isEmpty,
              let contact = contactTf.text, !contact.isEmpty,
              let gender = gender.text
        else {
            showAlert(title: "Error", message: "Looks like some fields are empty.")
            return
        }
        
      
        let adress = addressTf.text ?? ""
        let other = other.text ?? ""
        
        let id = ID.isEmpty ? generateOrderNumber() : ID
        
        let newRecord = DataSource(
            id: id,
            Name: name,
            contact: contact,
            address: adress,
            gender: gender,
            other: other
         
        )
        
        if let index = findRecordIndex(by: id) {
                // Update existing record
                updateSavedData(newRecord, at: index)
            } else {
                // Save new record
                saveCreateSaleDetail(newRecord)
            }
       
        
    }
    
    func saveCreateSaleDetail(_ order: DataSource) 
    {
        var orders = UserDefaults.standard.object(forKey: "customerRecord") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(order)
            orders.append(data)
            UserDefaults.standard.set(orders, forKey: "customerRecord")
            clearTextFields()
           
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Success", message: "The assignment has been successfully saved.")
        
    }
    
    func updateSavedData(_ updatedTranslation: DataSource, at index: Int) {
        if var savedData = UserDefaults.standard.array(forKey: "customerRecord") as? [Data] {
            let encoder = JSONEncoder()
            do {
                let updatedData = try encoder.encode(updatedTranslation)
                savedData[index] = updatedData // Update the specific index
                UserDefaults.standard.set(savedData, forKey: "customerRecord")
            } catch {
                print("Error encoding data: \(error.localizedDescription)")
            }
        }
        showAlert(title: "Updated", message: "Your record Has Been Updated Successfully.")
    }
    
    func findRecordIndex(by id: String) -> Int? {
        if let records = UserDefaults.standard.array(forKey: "customerRecord") as? [Data] {
            let decoder = JSONDecoder()
            for (index, recordData) in records.enumerated() {
                do {
                    let record = try decoder.decode(DataSource.self, from: recordData)
                    if record.id == id {
                        return index
                    }
                } catch {
                    print("Error decoding record: \(error.localizedDescription)")
                }
            }
        }
        return nil
    }

    func clearTextFields() 
    {
        nameTF.text = ""
        contactTf.text = ""
        gender.text = ""
        other.text = ""
        addressTf.text = ""
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        saveData()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    
}
