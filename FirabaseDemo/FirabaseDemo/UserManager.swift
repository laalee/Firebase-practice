//
//  UserManager.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/3.
//  Copyright © 2018年 laalee. All rights reserved.
//

import Foundation

class UserManager {
    
    static let shared = UserManager()
    
    func setUserKey(key: String) {
        
        UserDefaults.standard.set(key, forKey: "userKey")
    }
    
    func setUserEmail(key: String) {
        
        UserDefaults.standard.set(key, forKey: "userEmail")
    }
    
    func getUserKey() -> String? {
        
        let userKey = UserDefaults.standard.string(forKey: "userKey")
        
        return userKey
    }
    
    func getUserEmail() -> String? {
        
        let userEmail = UserDefaults.standard.string(forKey: "userEmail")
        
        return userEmail
    }
}
