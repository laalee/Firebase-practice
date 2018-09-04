//
//  FirebaseManager.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/4.
//  Copyright © 2018年 laalee. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseManager {
    
    static let shared = FirebaseManager()

    var ref: DatabaseReference = Database.database().reference()
    
    func signUpUser(
        userName: String,
        userEmail: String,
        success: @escaping () -> Void,
        failure: @escaping (String) -> Void
        ) {
        
        ref.child("member")
            .queryOrdered(byChild: "user_email")
            .queryEqual(toValue: userEmail)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard (snapshot.value as? NSDictionary) == nil else {
                    
                    failure("User exists.")
                    
                    return
                }
                
                let key = self.ref.child("member").childByAutoId().key
                
                self.ref
                    .child("member")
                    .child(key)
                    .setValue(["user_name": userName, "user_email": userEmail])
                
                UserManager.shared.setUserKey(key: key)
                UserManager.shared.setUserEmail(key: userEmail)

                success()
        }
    }
    
    func logInUser(
        userEmail: String,
        success: @escaping () -> Void,
        failure: @escaping (String) -> Void
        ) {
        
        ref.child("member")
            .queryOrdered(byChild: "user_email")
            .queryEqual(toValue: userEmail)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    failure("User not exist.")
                    
                    return
                }
                
                guard let userKey = value.allKeys[0] as? String else { return }
                
                UserManager.shared.setUserKey(key: userKey)
                UserManager.shared.setUserEmail(key: userEmail)
                
                success()
        }
    }
    
    func getAllPosts(
        success: @escaping ([Post]) -> Void,
        failure: @escaping (String) -> Void
        ) {
        
        var result: [Post] = []
        
        ref.child("posts")
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    failure("No Post")
                    
                    return
                }
                
                for postId in value.allKeys {
                    
                    guard let post = value[postId] as? NSDictionary else { return }
                    
                    let newPost = self.transformPost(post: post)
                    
                    result.append(newPost)
                }
                
                success(result)
            })
    }

    func queryPost(
        key: String,
        value: String,
        success: @escaping ([Post]) -> Void,
        failure: @escaping (String) -> Void
        ) {
        
        var result: [Post] = []
        
        ref.child("posts")
            .queryOrdered(byChild: key)
            .queryEqual(toValue: value)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else {
                    
                    failure("No Post in: \(key)")
                    
                    return
                }
                
                for postId in value.allKeys {
                    
                    guard let post = value[postId] as? NSDictionary else { return }
                    
                    let newPost = self.transformPost(post: post)
                    
                    result.append(newPost)
                }
                
                success(result)
            })
    }
    
    func transformPost(post: NSDictionary) -> Post {
        let post = Post(
            article_content: post["article_content"] as? String ?? "",
            article_id: post["article_id"] as? String ?? "",
            article_tag: post["article_tag"] as? String ?? "",
            article_title: post["article_title"] as? String ?? "",
            author: post["author"] as? String ?? "",
            author_tag: post["author_tag"] as? String ?? "",
            created_time: post["created_time"] as? String ?? ""
        )
        
        return post
    }
    
    func addPost(title: String, content: String, tag: String) {
        
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
        
        ref.child("member")
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
        
        ref.child("member")
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

        ref.child("member")
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
