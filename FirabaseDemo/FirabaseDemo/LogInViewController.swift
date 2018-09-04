//
//  LogInViewController.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/4.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var signSegment: UISegmentedControl!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func enterClick(_ sender: UIButton) {
        
        guard let name = nameTextField.text else { return }
        
        guard let mail = emailTextField.text else { return }
        
        switch signSegment.selectedSegmentIndex {
            
        case 0:
            FirebaseManager.shared.signUpUser(
                userName: name,
                userEmail: mail,
                success: {
                    self.showAlert(message: "Signup Success.")
                },
                failure: { error in
                    self.showAlert(message: error)
            })
            
        case 1:
            FirebaseManager.shared.logInUser(
                userEmail: mail,
                success: {
                    self.showAlert(message: "Login Success.")
                },
                failure: { error in
                    self.showAlert(message: error)
            })
            
        default: return
        }
    }
    
    func showAlert(message: String) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
