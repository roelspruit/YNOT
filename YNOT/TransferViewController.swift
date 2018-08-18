//
//  TransferViewController.swift
//  YNOT
//
//  Created by Roel Spruit on 07/07/2018.
//  Copyright © 2018 dinkywonder. All rights reserved.
//

import UIKit
import YNAB

class TransferViewController: UIViewController {

    @IBOutlet weak var donationAmountLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var donationButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var percentageButton: UIButton!
    @IBOutlet weak var payeeButton: UIButton!
    
    private var budgetDetail: BudgetDetail?
    private var ynabHelper = YNABHelper()
    
    var percentages: [Double] {
        return [
            0.01,
            0.025,
            0.05,
            0.1,
            0.15
        ]
    }
    
    let fontSize: CGFloat = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextField.text = "\(Settings.shared.expenseAmount)"
        
        updateUI()
        
        addButton.applyBorderAndShadow()
        
        topContainer.alpha = 0
        bottomContainer.alpha = 0
        
        percentageButton.tag = Settings.shared.donationPercentageIndex
        percentageUpdated(percentageButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.topContainer.alpha = 1.0
            
        }) { (_) in
            
            UIView.animate(withDuration: 0.5, animations: {
                self.bottomContainer.alpha = 1.0
            }, completion: nil)
        }
        
        ynabHelper.getYNABClient(presentingViewController: self) { (ynab) in
            
            ynab.getBudgets { (budgets) in
                
                guard let budget = budgets?.first(where: {$0.name == "YNOT"}) else {
                    print("Could not get test budget")
                    return
                }
                
                ynab.getBudget(budgetId: budget.id, completion: { (budgetDetail) in
                    self.budgetDetail = budgetDetail
                })
            }
        }
    }
    
    @IBAction func addExpense(_ sender: Any) {
        
        guard let budgetDetail = budgetDetail, let expenseCategory = Settings.shared.expenseCategory else {
            return
        }
        
        ynabHelper.getYNABClient(presentingViewController: self) { (ynab) in
            
            let account = budgetDetail.accounts.first(where: {$0.name == "TestAccount"})!
            
            let expensePayeeName = "Some Grocery Shop"
            
            let expenseTransaction = SaveTransaction(date: self.dateString,
                                                              amount: -Settings.shared.expenseAmount * 1000,
                                                              account_id: account.id,
                                                              category_id: expenseCategory.id,
                                                              approved: true,
                                                              cleared: .uncleared,
                                                              payee_name: expensePayeeName)
            
            ynab.createTransaction(transaction: expenseTransaction, budgetId: budgetDetail.id, completion: {(transaction) in
                self.createDonationTransactions(ynab: ynab, account: account)
            })
            
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let date = formatter.string(from: Date())
        return date
    }
    
    private func createDonationTransactions(ynab: YNABClient, account: Account) {
        
        guard let budgetDetail = budgetDetail,
            let expenseCategory = Settings.shared.expenseCategory,
            let donationsCategory = Settings.shared.donationsCategory else {
                return
        }
        
        let transferPayeeName = "YNOT"
        
        let donationTransferTransaction = SaveTransaction(date: self.dateString,
                                                          amount: -Settings.shared.donationAmount*1000,
                                                          account_id: account.id,
                                                          category_id: expenseCategory.id,
                                                          approved: true,
                                                          cleared: .cleared,
                                                          payee_name: transferPayeeName,
                                                          memo: "YNOT donation transfer to category '\(donationsCategory.name)'")
        
        ynab.createTransaction(transaction: donationTransferTransaction, budgetId: budgetDetail.id, completion: { (transaction) in
            
            let donationIncomingTransaction = SaveTransaction(date: self.dateString,
                                                              amount: Settings.shared.donationAmount*1000,
                                                              account_id: account.id,
                                                              category_id: donationsCategory.id,
                                                              approved: true,
                                                              cleared: .cleared,
                                                              payee_name: transferPayeeName,
                                                              memo: "YNOT donation transfer from category '\(expenseCategory.name)'")
            
            ynab.createTransaction(transaction: donationIncomingTransaction, budgetId: budgetDetail.id, completion: { (transaction) in
                
                DispatchQueue.main.async {
                    self.addButton.setTitle("Logged and donated!", for: .normal)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        self.addButton.setTitle("Add expense and donate", for: .normal)
                    })
                }
                
            })
        })
    }
    
    @IBAction func selectCategory(_ sender: Any) {
        
        ynabHelper.getYNABClient(presentingViewController: self) { [weak self] (ynab) in
            ynab.getBudgets { (budgets) in
                
                guard let budget = budgets?.first(where: {$0.name == "YNOT"}) else {
                    print("Could not get test budget")
                    return
                }
                
                let table = YNCategoryTableViewController(client: ynab,
                                                          budgetId: budget.id,
                                                          selectedCategory: Settings.shared.expenseCategory,
                                                          categorySelected: { (category) in
                    
                    print("Category selected: \(category.name)")
                    Settings.shared.expenseCategory = category
                    Settings.shared.store()
                    self?.updateUI()
                })
                
                self?.present(UINavigationController(rootViewController: table), animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func selectPayee(_ sender: Any) {
        
        ynabHelper.getYNABClient(presentingViewController: self) { [weak self] (ynab) in
            ynab.getBudgets { (budgets) in
                
                guard let budget = budgets?.first(where: {$0.name == "YNOT"}) else {
                    print("Could not get test budget")
                    return
                }
                
                let table = YNPayeeTableViewController(client: ynab, budgetId: budget.id, selectedPayee: Settings.shared.payee, payeeSelected: { (payee) in
                    
                    print("Payee selected: \(payee.name)")
                    Settings.shared.payee = payee
                    Settings.shared.store()
                    self?.updateUI()
                })
                
                self?.present(UINavigationController(rootViewController: table), animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func selectDonationCategory(_ sender: Any) {
        
        ynabHelper.getYNABClient(presentingViewController: self) { [weak self] (ynab) in
            ynab.getBudgets { (budgets) in
                
                guard let budget = budgets?.first(where: {$0.name == "YNOT"}) else {
                    print("Could not get test budget")
                    return
                }
                
                let table = YNCategoryTableViewController(client: ynab,
                                                          budgetId: budget.id,
                                                          selectedCategory: Settings.shared.donationsCategory,
                                                          categorySelected: { (category) in
                    
                    print("Category selected: \(category.name)")
                    Settings.shared.donationsCategory = category
                    Settings.shared.store()
                    self?.updateUI()
                })
                
                self?.present(UINavigationController(rootViewController: table), animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnPercentageClicked(_ sender: UIButton) {
        if sender.tag == percentages.count - 1 {
            sender.tag = 0
        } else {
            sender.tag += 1
        }
        
        percentageUpdated(sender)
    }
    
    private func percentageUpdated(_ button: UIButton) {
        Settings.shared.donationPercentageIndex = button.tag
        Settings.shared.donationPercentage = self.percentages[Settings.shared.donationPercentageIndex]
        
        button.setTitle("\(Settings.shared.donationPercentage * 100)%", for: .normal)
        Settings.shared.store()
        self.updateUI()
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.updateCategory()
            self.updateBudget()
            self.updateDonation()
            self.updatePayee()
            
            self.addButton.isEnabled = Settings.shared.isComplete
            self.addButton.alpha = Settings.shared.isComplete ? 1.0 : 0.3
        }
    }
    
    private var ctaColor: UIColor {
        return UIColor(red: 23.0/255.0, green: 151.0/255.0, blue: 186.0/255.0, alpha: 1.0)
    }
    
    private func updateCategory() {
        
        let category = NSMutableAttributedString()
        
        if let categoryName = Settings.shared.expenseCategory?.name {
            
            category.append(NSAttributedString(string: categoryName, attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedStringKey.foregroundColor: UIColor.black
            ]))
            
        } else {
            category.append(NSAttributedString(string: "Pick a category", attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray
            ]))
        }
        
        self.categoryButton.setAttributedTitle(category, for: .normal)
    }
    
    private func updateBudget() {
        let donationText = NSMutableAttributedString()
        
        if let categoryName = Settings.shared.donationsCategory?.name {
            
            donationText.append(NSAttributedString(string: categoryName, attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedStringKey.foregroundColor: UIColor.black
            ]))
            
        } else {
            
            donationText.append(NSAttributedString(string: "Pick a donation category", attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray
            ]))
        }
        
        self.donationButton.setAttributedTitle(donationText, for: .normal)
    }
    
    private func updatePayee() {
        let payeeText = NSMutableAttributedString()
        
        if let payeeName = Settings.shared.payee?.name {
            
            payeeText.append(NSAttributedString(string: payeeName, attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedStringKey.foregroundColor: UIColor.black
                ]))
            
        } else {
            
            payeeText.append(NSAttributedString(string: "Pick a payee", attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray
                ]))
        }
        
        self.payeeButton.setAttributedTitle(payeeText, for: .normal)
    }
    
    private func updateDonation() {
        donationAmountLabel.text = formatCurrency(Settings.shared.donationAmount)
    }
}

extension TransferViewController: UITextFieldDelegate {
    
    private func formatCurrency(_ amount: Double) -> String {
        return String(format: "%.02f", amount)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            if let amountDouble = Double(updatedText) {
                Settings.shared.expenseAmount = amountDouble
                Settings.shared.store()
                self.updateUI()
            }
            
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text,
            let amountDouble = Double(text) {
            textField.text = formatCurrency(amountDouble)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

