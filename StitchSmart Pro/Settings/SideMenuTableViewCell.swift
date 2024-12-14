//
//  SideMenuTableViewCell.swift
//  Flip & Bet
//
//  Created by Moin Janjua on 12/08/2024.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var sidemenu_label: UILabel!
    @IBOutlet weak var bgview: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgview.layer.cornerRadius = 12
        
        // Set up shadow properties
        bgview.layer.shadowColor = UIColor.white.cgColor
        bgview.layer.shadowOffset = CGSize(width: 0, height: 2)
        bgview.layer.shadowOpacity = 0.3
        bgview.layer.shadowRadius = 4.0
        bgview.layer.masksToBounds = false
        
        // Set background opacity
        bgview.alpha = 1.5 // Adjust opacity as needed
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
