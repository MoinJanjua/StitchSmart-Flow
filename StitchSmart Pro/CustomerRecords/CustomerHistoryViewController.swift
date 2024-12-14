//
//  CustomerHistoryViewController.swift
//  StitchSmart Pro
//
//  Created by Unique Consulting Firm on 11/12/2024.
//

import UIKit

class CustomerHistoryViewController: UIViewController  ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var datasource: [DataSource] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       

        if let savedData = UserDefaults.standard.array(forKey: "customerRecord") as? [Data] {
            let decoder = JSONDecoder()
            datasource = savedData.compactMap { data in
                do {
                    let productsData = try decoder.decode(DataSource.self, from: data)
                    return productsData
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        noDataLabel.text = "No Customers Found"// Set the message
        // Show or hide the table view and label based on data availability
               if datasource.isEmpty {
                   TableView.isHidden = true
                   noDataLabel.isHidden = false  // Show the label when there's no data
               } else {
                   TableView.isHidden = false
                   noDataLabel.isHidden = true   // Hide the label when data is available
               }
        print(datasource)  // Check if data is loaded
        TableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomerhistoryTableViewCell
        
        let record = datasource[indexPath.item]
        cell.namelb.text = record.Name
        cell.contactlb.text = record.contact
        cell.genderlb.text = "Gender : \(record.gender)"
        
        cell.updateButtonAction = { [weak self] in
        guard let self = self else { return }
        self.navigateToUpdate(record: record)
        }
        
        cell.orderButtonAction = { [weak self] in
        guard let self = self else { return }
        self.navigateToOrder(record: record)
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }
    
    
    func navigateToUpdate(record: DataSource) 
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "createCustomerViewController") as! createCustomerViewController
        newViewController.ID = record.id
        newViewController.selectedRceord = record
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func navigateToOrder(record: DataSource) 
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "BookingHistoryViewController") as! BookingHistoryViewController
        newViewController.ID = record.id
        //newViewController.selectedRceord = record
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }

    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func removeAllButton(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "customerRecord")
        UserDefaults.standard.removeObject(forKey: "bookingRecord")
        datasource.removeAll()
        TableView.reloadData()
        noDataLabel.text = "No Customers Found"// Set the message
        // Show or hide the table view and label based on data availability
       if datasource.isEmpty {
           TableView.isHidden = true
           noDataLabel.isHidden = false  // Show the label when there's no data
       } else {
           TableView.isHidden = false
           noDataLabel.isHidden = true   // Hide the label when data is available
       }
    }
}
