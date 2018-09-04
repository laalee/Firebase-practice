//
//  SearchViewController.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/4.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchResultView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBOutlet weak var tagSegment: UISegmentedControl!
    
    @IBOutlet weak var postsTableView: UITableView!
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResultView.isHidden = true
        noResultLabel.isHidden = true
    }

    @IBAction func searchClick(_ sender: UIButton) {
        
        guard let email = searchTextField.text else { return }
        
        FirebaseManager.shared.searchMember(
            userEmail: email,
            success: { (_, name, email) in
                
                self.nameLabel.text = name
                
                self.emailLabel.text = email
                
                self.searchResultView.isHidden = false
                
                self.noResultLabel.isHidden = true
            },
            failure: {
                
                self.searchResultView.isHidden = true
                
                self.noResultLabel.isHidden = false
        })
    }
    
    @IBAction func addFriendClick(_ sender: UIButton) {
        
        guard let email = emailLabel.text else { return }
        
        FirebaseManager.shared.addFriend(userEmail: email)
        
        addFriendButton.setTitle("待邀請", for: .normal)
        
//        addFriendButton.isEnabled = false
    }
    
}
