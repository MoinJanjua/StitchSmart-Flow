//
//  WelcomeViewController.swift
//  StitchSmart Pro
//
//  Created by Unique Consulting Firm on 10/12/2024.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        roundCorner(button: proceedButton)
    
    }
    
    @IBAction func continueButtonTapped()
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
}
