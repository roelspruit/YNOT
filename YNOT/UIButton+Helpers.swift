//
//  UIButton+Helpers.swift
//  YNOT
//
//  Created by Roel Spruit on 24/07/2018.
//  Copyright © 2018 dinkywonder. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func applyBorderAndShadow() {
        
        layer.shadowColor = UIColor(red: 19.0/255.0, green: 50.0/255.0, blue: 60.0/255.0, alpha: 1.0).cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.cornerRadius = 25
        clipsToBounds = false
    }
}
