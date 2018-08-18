//
//  OnboardViewController.swift
//  YNOT
//
//  Created by Roel Spruit on 24/07/2018.
//  Copyright © 2018 dinkywonder. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.applyBorderAndShadow()
    }
    
    @IBAction func login(_ sender: Any) {
        YNABHelper().getYNABClient(presentingViewController: self) { (client) in
            // logged in
            self.performSegue(withIdentifier: "LOGGEDIN", sender: nil)
        }
    }
}
