//
//  ViewController.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/3.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit
import FirebaseDatabase

enum DataBaseType: String {
    case member
    case posts
}

class ViewController: UIViewController {
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
//        setUser()
        
//        getUser()
        
//        setArticle()
        
//        getArticle()
        
//        queryArticle()
        
        observeFriend()
    }
    
    func setUser() {

        let key = ref.child(DataBaseType.member.rawValue).childByAutoId().key

        let userName = "Annie"

        let userEmail = "annie@haha.com"

        self.ref
            .child(DataBaseType.member.rawValue)
            .child(key)
            .setValue(["user_name": userName, "user_email": userEmail])
        
        UserManager.shared.setUserKey(key: key)
    }
    
    func getUser() {

        guard let userID = UserManager.shared.getUserKey() else { return }

        ref.child(DataBaseType.member.rawValue)
            .child(userID)
            .observeSingleEvent(of: .value, with: { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            let userName = value["user_name"] as? String

            let userEmail = value["user_email"] as? String

        }) { (error) in
            
            print(error.localizedDescription)
        }
    }
    
    func setArticle() {
        
        let key = ref.child("posts").childByAutoId().key
        
        let articleContent = "TTTTTTestttttt"
        
        let articleId = key
        
        let articleTag = "八卦"
        
        let articleTitle = "HIIIIIII"
        
        let author = UserManager.shared.getUserKey()
        
        let createdTime = getCurrentTime()
        
        self.ref
            .child(DataBaseType.posts.rawValue)
            .child(key)
            .setValue(["article_content": articleContent,
                                                      "article_id": articleId,
                                                      "article_tag": articleTag,
                                                      "article_title": articleTitle,
                                                      "author": author,
                                                      "created_time": createdTime])
    }
    
    func getArticle(key: String) {

        ref.child(DataBaseType.posts.rawValue)
            .child(key)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else { return }
                
                print(value)
                
            }) { (error) in
                
                print(error.localizedDescription)
        }
    }
    
    func queryArticle() {
        
        let queryValue = "-LLTbxZuWQQDG72HYcdd"

        ref.child(DataBaseType.posts.rawValue)
            .queryOrdered(byChild: "author")
            .queryEqual(toValue: queryValue)
            .observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else { return }
            
            print(value.allKeys[0])
            
            self.getArticle(key: value.allKeys[0] as! String)
        })

    }
    
    func observeFriend() {
        
        guard let user = UserManager.shared.getUserKey() else { return }
        
        ref.child(DataBaseType.member.rawValue)
            .child(user)
            .observe(.childAdded, with: { (snapshot) -> Void in
                
            print(snapshot)
        })
    }
    
    func getCurrentTime() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        let result = formatter.string(from: date)
        
        return result
    }

}

