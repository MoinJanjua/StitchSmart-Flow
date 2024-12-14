//
//  BookingHistoryViewController.swift
//  StitchSmart Pro
//
//  Created by Unique Consulting Firm on 11/12/2024.
//

import UIKit

class BookingHistoryViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var datasource: [bookingRecord] = []
    var selectedRceord: bookingRecord?
    var ID = String()
    var customerRecord = [DataSource]()
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        if !(ID.isEmpty)
        {
            if let savedData = UserDefaults.standard.array(forKey: "bookingRecord") as? [Data] 
            {
                let decoder = JSONDecoder()
                datasource = savedData.compactMap { data in
                    do {
                        let productsData = try decoder.decode(bookingRecord.self, from: data)
                        print("productsData",productsData)
                        return productsData
                    } catch {
                        print("Error decoding product: \(error.localizedDescription)")
                        return nil
                    }
                }.filter({ $0.referenceId.trimmingCharacters(in: .whitespacesAndNewlines) == ID}).filter({ $0.clothType.trimmingCharacters(in: .whitespacesAndNewlines) != ""})
             }
            
            noDataLabel.text = "No Bookings Found"// Set the message
            // Show or hide the table view and label based on data availability
                   if datasource.isEmpty {
                       TableView.isHidden = true
                       noDataLabel.isHidden = false  // Show the label when there's no data
                   } else {
                       TableView.isHidden = false
                       noDataLabel.isHidden = true   // Hide the label when data is available
                   }
            print(datasource)  // Check if data is loaded
            getCustomerrecord()
           
            return
        }

        if let savedData = UserDefaults.standard.array(forKey: "bookingRecord") as? [Data] {
            let decoder = JSONDecoder()
            datasource = savedData.compactMap { data in
                do {
                    let productsData = try decoder.decode(bookingRecord.self, from: data)
                    print("productsData",productsData)
                    return productsData
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                    return nil
                }
            }.filter({ $0.clothType.trimmingCharacters(in: .whitespacesAndNewlines) != ""})
        }
        noDataLabel.text = "No Bookings Found"// Set the message
        // Show or hide the table view and label based on data availability
               if datasource.isEmpty {
                   TableView.isHidden = true
                   noDataLabel.isHidden = false  // Show the label when there's no data
               } else {
                   TableView.isHidden = false
                   noDataLabel.isHidden = true   // Hide the label when data is available
               }
        getCustomerrecord()  // Check if data is loaded
       
    }
    
    
    func getCustomerrecord() {
        if let savedData = UserDefaults.standard.array(forKey: "customerRecord") as? [Data] {
            let decoder = JSONDecoder()
            customerRecord = savedData.compactMap { data in
                do {
                    let productsData = try decoder.decode(DataSource.self, from: data)
                    return productsData
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                    return nil
                }
            }
        }

        print("Customer Record:", customerRecord)
        
        for cust_rec in customerRecord {
                // Find all matching records in datasource for this customer
                let matchingRecords = datasource.enumerated().filter { $0.element.referenceId == cust_rec.id }
                
                for (index, _) in matchingRecords {
                    // Update the properties for each matching record
                    datasource[index].gender = cust_rec.gender
                    datasource[index].contact = cust_rec.contact
                }
            }
        TableView.reloadData()
    }

    
    func updateUI() 
    {
       noDataLabel.text = "No Bookings Found"
       if datasource.isEmpty {
           TableView.isHidden = true
           noDataLabel.isHidden = false
       } else {
           TableView.isHidden = false
           noDataLabel.isHidden = true
       }
       TableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! bookinghistoryTableViewCell
        
        let rec = datasource[indexPath.item]
        cell.namelb.text = rec.Name
        cell.contactlb.text = rec.contact
        cell.genderlb.text = "Gender : \(rec.gender)"
        cell.typelb.text = "Type : \(rec.clothType)"
        cell.deliverDatelb.text = "Date of delivery : \(rec.deliveryDate)"
        cell.bookingdtaeb.text = "Date of delivery : \(rec.bookingdate)"

        cell.updateButtonAction = { [weak self] in
            guard let self = self else { return }
            self.navigateToOrder(record: rec)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 162
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              // Remove record from datasource
              datasource.remove(at: indexPath.row)

              // Update UserDefaults
              let encoder = JSONEncoder()
              let updatedData = datasource.compactMap { try? encoder.encode($0) }
              UserDefaults.standard.set(updatedData, forKey: "bookingRecord")

              // Delete row from table view
              tableView.deleteRows(at: [indexPath], with: .fade)

              // Update UI
              updateUI()
          }
      }
    
    func navigateToOrder(record: bookingRecord)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CreateBookingViewController") as!  CreateBookingViewController
        newViewController.selectedRecordID = record.id
        newViewController.selectedRceord = record
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func removeAllButton(_ sender: Any) {
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
