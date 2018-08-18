//
//  Settings.swift
//  YNOT
//
//  Created by Roel Spruit on 11/07/2018.
//  Copyright © 2018 dinkywonder. All rights reserved.
//

import Foundation
import YNAB

struct Settings: Codable {
    
    public static var shared = Settings()
    
    var budget: YNAB.BudgetSummary?
    var expenseCategory: YNAB.Category?
    var donationsCategory: YNAB.Category?
    var accessToken: AccessToken?
    var payee: Payee?
    
    var expenseAmount: Double = 0
    var donationPercentageIndex: Int = 0
    var donationPercentage: Double = 0.01
    var donationAmount: Double {
        return expenseAmount * donationPercentage
    }
    
    var isComplete: Bool {
        
        if let accessToken = accessToken,
            !accessToken.expired,
            expenseCategory != nil,
            donationsCategory != nil,
            donationAmount > 0{
            return true
        }
        
        return false
    }
}

extension Settings {
    
    static var fromDefaults: Settings? {
        
        let decoder = JSONDecoder()
        
        if let settingsData = UserDefaults.standard.object(forKey: "settings") as? Data {
            return try? decoder.decode(Settings.self, from: settingsData)
        }
        
        return nil
    }
    
    func store() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: "settings")
        }
    }
}
