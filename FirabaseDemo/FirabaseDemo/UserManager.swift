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
    
    func getUserKey() -> String? {
        
        guard let userKey = UserDefaults.standard.string(forKey: "userKey") else {
            return nil
        }
        
        return userKey
    }
}
