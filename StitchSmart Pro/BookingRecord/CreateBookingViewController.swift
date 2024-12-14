import UIKit

class CreateBookingViewController: UIViewController {
    
    @IBOutlet weak var nameTF: DropDown!
    @IBOutlet weak var bookingDateTF: UIDatePicker!
    @IBOutlet weak var clothTypeTF: DropDown!
    @IBOutlet weak var deliveryDateTF: UIDatePicker!
    @IBOutlet weak var measurementTV: UITextView!
    @IBOutlet weak var switchbtn: UISwitch!
    
    var customerRecords: [DataSource] = [] // To store fetched records
    var bookingRecords: [bookingRecord] = [] // To store fetched records
    var selectedRceord: bookingRecord?
    var selectedRecordID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRecords()
        setupNameDropdown()
        let notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
           switchbtn.isOn = notificationsEnabled
        if !(selectedRecordID?.isEmpty ?? false)
        {
            nameTF.text = selectedRceord?.Name
           // bookingDateTF.date = selectedRceord?.bookingdate
            clothTypeTF.text = selectedRceord?.clothType
           // deliveryDateTF.date = selectedRceord?.gender
            measurementTV.text = selectedRceord?.measurement
            
            if let bookingDateString = selectedRceord?.bookingdate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust this to match your date format
                if let bookingDate = dateFormatter.date(from: bookingDateString) {
                    bookingDateTF.date = bookingDate
                } else {
                    print("Invalid date format")
                }
            } else {
                print("bookingdate is nil")
            }
            
            if let bookingDateString = selectedRceord?.deliveryDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust this to match your date format
                if let bookingDate = dateFormatter.date(from: bookingDateString) {
                    deliveryDateTF.date = bookingDate
                } else {
                    print("Invalid date format")
                }
            } else {
                print("bookingdate is nil")
            }
            
            measurementTV.layer.cornerRadius = 10
            measurementTV.clipsToBounds = true

        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard()
    {
       view.endEditing(true)
    }
    // Fetch records from UserDefaults
    func fetchRecords() {
        if let savedData = UserDefaults.standard.array(forKey: "customerRecord") as? [Data] {
            let decoder = JSONDecoder()
            customerRecords = savedData.compactMap { data in
                do {
                    return try decoder.decode(DataSource.self, from: data)
                } catch {
                    print("Error decoding record: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }
    
    // Setup dropdown for name selection
    func setupNameDropdown() {
        nameTF.optionArray = customerRecords.map { $0.Name } // Populate dropdown with names
        nameTF.didSelect { [weak self] selectedName, index, _ in
            guard let self = self else { return }
            let selectedRecord = self.customerRecords[index]
            self.selectedRecordID = selectedRecord.id
            nameTF.text = selectedName
            // self.updateFields(with: selectedRecord)
        }
        clothTypeTF.optionArray = ["Suit","Shirts","Kurta","Jackets","Blouses","Pants","Skirts","Salwar","Lehenga"]
        clothTypeTF.didSelect { [weak self] selectedName, index, _ in
            self?.clothTypeTF.text = selectedName
        }
    }
    
    
    @IBAction func SaveButton(_ sender: Any) {
        let refId = generateCustomerId() // Generate a unique ID for the new record
        
        // Create a new booking record from the form inputs
        let newRecord = bookingRecord(
            id: "\(refId)",
            Name: nameTF.text ?? "",
            bookingdate: bookingDateTF.date.toString(),
            deliveryDate: deliveryDateTF.date.toString(),
            clothType: clothTypeTF.text ?? "",
            measurement: measurementTV.text ?? "",
            referenceId: selectedRecordID ?? "\(refId)", // Use existing referenceId or new refId
            gender:selectedRceord?.gender ?? "",
            contact: selectedRceord?.contact ?? ""
        )
        
        // Retrieve existing booking records from UserDefaults
        var orders = UserDefaults.standard.object(forKey: "bookingRecord") as? [Data] ?? []
        
        // Update if a record with the same ID exists, otherwise append as new
        if let selectedID = selectedRecordID,
           let recordIndex = orders.firstIndex(where: {
               let decoder = JSONDecoder()
               guard let existingRecord = try? decoder.decode(bookingRecord.self, from: $0) else { return false }
               return existingRecord.id == selectedID
           }) {
            // Update the existing record
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(newRecord)
                orders[recordIndex] = data
                print("Record updated successfully.")
            } catch {
                print("Error encoding record: \(error.localizedDescription)")
            }
        } else {
            // Append as a new record
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(newRecord)
                orders.append(data)
                print("New record created successfully.")
            } catch {
                print("Error encoding record: \(error.localizedDescription)")
            }
        }
        
        // Save the updated records back to UserDefaults
        UserDefaults.standard.set(orders, forKey: "bookingRecord")
        clearTextFields()
        showAlert(title: "Success", message: "The record has been successfully saved.")
        let name = "\(nameTF.text ?? "Customer") \(clothTypeTF.text ?? "")"
        scheduleNotification(for: deliveryDateTF.date, withName: name)

    }

    func saveCreateSaleDetail(_ order: bookingRecord)
    {
        var orders = UserDefaults.standard.object(forKey: "bookingRecord") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(order)
            orders.append(data)
            UserDefaults.standard.set(orders, forKey: "bookingRecord")
            clearTextFields()
            
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Success", message: "The record has been successfully saved.")
        
    }
    
    func clearTextFields()
    {
        nameTF.text = ""
        clothTypeTF.text = ""
        measurementTV.text = ""
        
    }
    
    
    func scheduleNotification(for deliveryDate: Date, withName name: String) {
        let content = UNMutableNotificationContent()
        content.title = "Delivery Reminder"
        content.body = "Hi \(name), delivery is scheduled for today!"
        content.sound = .default
        
        // Set the notification to trigger at 9:00 AM on the delivery date
        var triggerDate = Calendar.current.dateComponents([.year, .month, .day], from: deliveryDate)
        triggerDate.hour = 9
        triggerDate.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications have been canceled.")
    }

    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func swittchbtn(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "notificationsEnabled")
        if sender.isOn {
            print("Notifications enabled.")
        } else {
            cancelAllNotifications()
            print("Notifications disabled.")
        }
    }

}


