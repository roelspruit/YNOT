//
//  BudgetSelectionViewController.swift
//  YNOT
//
//  Created by Roel Spruit on 01/08/2018.
//  Copyright © 2018 dinkywonder. All rights reserved.
//

import UIKit
import YNAB

class BudgetSelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectBudget(_ sender: Any) {
        YNABHelper().getYNABClient(presentingViewController: self) { (client) in
            
            let table = YNBudgetTableViewController(client: client, selectedBudget: nil, budgetSelected: { (budgetSummary) in
                Settings.shared.budget = budgetSummary
                Settings.shared.store()
                self.switchToMainUI()
            })
            
            self.present(table, animated: true)
        }
    }
    
    private func switchToMainUI() {
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            window.rootViewController = storyBoard.instantiateViewController(withIdentifier: "MainUI")
        })
    }
    
}
