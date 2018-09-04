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
                UserManager.shared.setUserEmail(key: userEmail)

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
                UserManager.shared.setUserEmail(key: userEmail)
                
                self.firebaseDelegate?.logInComplete(result: true)
        }
    }
    
    func postArticle(title: String, content: String, tag: String) {
        
        let key = ref.child("posts").childByAutoId().key
        
        let createdTime = getCurrentTime()
                
        guard let authorEmail = UserManager.shared.getUserEmail() else { return }
        
        let post = [
            "article_content": content,
            "article_id": key,
            "article_tag": tag,
            "article_title": title,
            "author": authorEmail,
            "author_tag": authorEmail+tag,
            "created_time": createdTime
        ]
        
        let childUpdates = ["/posts/\(key)": post]
        
        ref.updateChildValues(childUpdates)
    }
    
    func getCurrentTime() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        let result = formatter.string(from: date)
        
        return result
    }
    
    func searchMember(
            userEmail: String
            , success: @escaping (String, String, String) -> Void
            , failure: @escaping () -> Void
        ) {
        
        ref.child(DataBaseType.member.rawValue)
            .queryOrdered(byChild: "user_email")
            .queryEqual(toValue: userEmail)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    failure()
                    
                    return
                }
                
                guard let userId = value.allKeys[0] as? String else { return }
                
                guard let member = value[userId] as? NSDictionary else { return }
                
                guard let userName = member["user_name"] as? String else { return }
                
                guard let userEmail = member["user_email"] as? String else { return }
                
                success(userId, userName, userEmail)
        }
    }
    
    func searchMember(
            userKey: String,
            success: @escaping (String, String, String) -> Void,
            failure: @escaping (String) -> Void
        ) {
        
        ref.child(DataBaseType.member.rawValue)
            .child(userKey)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    failure("no value")
                    
                    return
                }
                
                guard let userName = value["user_name"] as? String else { return }
                
                guard let userEmail = value["user_email"] as? String else { return }
                
                success(userKey, userName, userEmail)
                
            }) { (error) in
                
                failure("error")
        }
    }
    
    func addFriend(userEmail: String) {
        
        guard let userKey = UserManager.shared.getUserKey() else { return }
        
        searchMember(
            userEmail: userEmail,
            success: { (friendkey, _, _) in
                
                print("add")
                
                let userStatus = ["invite_status": "pending_send"]
                let friendStatus = ["invite_status": "pending_confirm"]
                
                let childUpdates = [
                    "/member/\(userKey)/friend/\(friendkey)": userStatus,
                    "/member/\(friendkey)/friend/\(userKey)": friendStatus
                ]
                
                self.ref.updateChildValues(childUpdates)
            },
            failure: {
                print("update fail")
        })
        
    }
    
    func confirmFriend(friendkey: String) {
        
        guard let userKey = UserManager.shared.getUserKey() else { return }
        
        let userStatus = ["invite_status": "valid"]
        let friendStatus = ["invite_status": "valid"]
        
        let childUpdates = [
            "/member/\(userKey)/friend/\(friendkey)": userStatus,
            "/member/\(friendkey)/friend/\(userKey)": friendStatus
        ]
        
        self.ref.updateChildValues(childUpdates)
        
    }
    
    func deleteFriend(friendkey: String) {
        
        guard let userKey = UserManager.shared.getUserKey() else { return }

        ref.child("member").child(userKey).child("friend").child(friendkey).removeValue()
        ref.child("member").child(friendkey).child("friend").child(userKey).removeValue()
    }
    
    func getFriends(
            tag: String,
            success: @escaping (String, String, String) -> Void,
            failure: @escaping () -> Void,
            complete: @escaping () -> Void
        ) {
        
        guard let userKey = UserManager.shared.getUserKey() else { return }

        ref.child(DataBaseType.member.rawValue)
            .child(userKey)
            .child("friend")
            .queryOrdered(byChild: "invite_status")
            .queryEqual(toValue: tag)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    failure()
                    
                    return
                }
                
                for index in 0..<value.allKeys.count {
                    
                    guard let userId = value.allKeys[index] as? String else { return }
                    
                    self.searchMember(
                        userKey: userId,
                        success: { (key, name, email) in
                            
                            success(key, name, email)
                            
                            if index == value.allKeys.count - 1 {
                                
                                complete()
                            }
                        },
                        failure: {_ in
                            
                            failure()
                    })
                    
                }
        }
    }
    
}
