//
//  TabBarViewController.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/4.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TabBarViewController: UITabBarController {
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        observeFriend()
    }
    
    func observeFriend() {
        
        guard let user = UserManager.shared.getUserKey() else { return }
        
        ref.child("member")
            .child(user)
            .child("friend")
            .observe(.childAdded, with: { (snapshot) -> Void in
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("UPDATE_FRIEND"),
                    object: nil
                )
            })
        
        ref.child("member")
            .child(user)
            .child("friend")
            .observe(.childChanged, with: { (snapshot) -> Void in
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("UPDATE_FRIEND"),
                    object: nil
                )
            })
        ref.child("member")
            .child(user)
            .child("friend")
            .observe(.childRemoved, with: { (snapshot) -> Void in
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("UPDATE_FRIEND"),
                    object: nil
                )
            })
    }

}
