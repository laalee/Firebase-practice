//
//  FirebaseManager.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/4.
//  Copyright © 2018年 laalee. All rights reserved.
//

import Foundation
import FirebaseDatabase

enum DataBaseType: String {
    case member
    case posts
}

protocol FirebaseDelegate: AnyObject {
    
    func signUpComplete(result: Bool)
    
    func logInComplete(result: Bool)
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    var firebaseDelegate: FirebaseDelegate?
    
    var ref: DatabaseReference = Database.database().reference()
    
    func signUpUser(userName: String, userEmail: String) {
        
        ref.child(DataBaseType.member.rawValue)
            .queryOrdered(byChild: "user_email")
            .queryEqual(toValue: userEmail)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard (snapshot.value as? NSDictionary) == nil else {
                    
                    self.firebaseDelegate?.signUpComplete(result: false)
                    
                    return
                }
                
                let key = self.ref.child(DataBaseType.member.rawValue).childByAutoId().key
                
                self.ref
                    .child(DataBaseType.member.rawValue)
                    .child(key)
                    .setValue(["user_name": userName, "user_email": userEmail])
                
                UserManager.shared.setUserKey(key: key)
                
                self.firebaseDelegate?.signUpComplete(result: true)
        }
    }
    
    
    func logInUser(userEmail: String) {
        
        ref.child(DataBaseType.member.rawValue)
            .queryOrdered(byChild: "user_email")
            .queryEqual(toValue: userEmail)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    self.firebaseDelegate?.logInComplete(result: false)
                    
                    return
                }
                
                guard let userKey = value.allKeys[0] as? String else { return }
                
                UserManager.shared.setUserKey(key: userKey)
                
                self.firebaseDelegate?.logInComplete(result: true)
        }
    }
    
    func queryUser(userEmail: String) {
        
        let queryValue = "-LLTbxZuWQQDG72HYcdd"
        
        ref.child(DataBaseType.posts.rawValue)
            .queryOrdered(byChild: "author")
            .queryEqual(toValue: queryValue)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else { return }
                
                print(value.allKeys[0])
                
//                self.getArticle(key: value.allKeys[0] as! String)
            })
        
    }
    
    
}
