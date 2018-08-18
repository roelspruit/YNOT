//
//  YNABHelper.swift
//  YNOT
//
//  Created by Roel Spruit on 24/07/2018.
//  Copyright © 2018 dinkywonder. All rights reserved.
//

import Foundation
import YNAB

class YNABHelper {
    
    func getYNABClient(presentingViewController: UIViewController,
                       completion: ((_ client: YNABClient) -> Void)?) {
        
        if let token = Settings.shared.accessToken, !token.expired {
            completion?(YNABClient(accessToken: token))
            return
        }
        
        let clientId = "4c2d4e5ffdcbe71c501764d2560ccda24765f95a9b24a324f9bb6cc7f994f23b"
        let redirectUri = "https://www.roelspruit.com/ynot/"
        
        let authorize = YNLoginViewController(clientId: clientId, redirectUri: redirectUri) { (accessToken) in
            guard let accessToken = accessToken else {
                print("YNAB Authorisation failed or was cancelled by user")
                return
            }
            
            Settings.shared.accessToken = accessToken
            Settings.shared.store()
            
            completion?(YNABClient(accessToken: accessToken))
        }
        
        presentingViewController.present(UINavigationController(rootViewController: authorize), animated: true, completion: nil)
    }
}
