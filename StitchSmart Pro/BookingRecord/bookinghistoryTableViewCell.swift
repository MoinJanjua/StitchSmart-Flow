//
//  bookinghistoryTableViewCell.swift
//  StitchSmart Pro
//
//  Created by Unique Consulting Firm on 11/12/2024.
//

import UIKit

class bookinghistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var namelb: UILabel!
    @IBOutlet weak var contactlb: UILabel!
    @IBOutlet weak var genderlb: UILabel!
    @IBOutlet weak var typelb: UILabel!
    @IBOutlet weak var deliverDatelb: UILabel!
    @IBOutlet weak var bookingdtaeb: UILabel!
    @IBOutlet weak var bgview: UIView!
    
    var updateButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func orderButtonTapped(_ sender: UIButton) {
            // Call the closure when the Update button is tapped
        updateButtonAction?()
        }
    
}
