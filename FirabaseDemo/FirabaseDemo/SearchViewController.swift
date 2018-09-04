//
//  SearchViewController.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/4.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchResultView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBOutlet weak var tagSegment: UISegmentedControl!
    
    @IBOutlet weak var postTableView: UITableView!
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResultView.isHidden = true
        noResultLabel.isHidden = true
        
        postTableView.dataSource = self
        postTableView.delegate = self
        
        let uiNib = UINib(nibName: "PostTableViewCell", bundle: nil)
        postTableView.register(uiNib, forCellReuseIdentifier: "Cell")
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
                
                self.getPosts()
                
                self.addFriendButton.setTitle("Add Friend", for: .normal)
                
                self.addFriendButton.isEnabled = true
                
                self.addFriendButton.backgroundColor = UIColor.darkGray
            },
            failure: {
                
                self.searchResultView.isHidden = true
                
                self.noResultLabel.isHidden = false
        })
    }
    
    @IBAction func addFriendClick(_ sender: UIButton) {
        
        guard let email = emailLabel.text else { return }
        
        guard email != UserManager.shared.getUserEmail() else { return }
        
        FirebaseManager.shared.addFriend(userEmail: email)
        
        addFriendButton.setTitle("已邀請", for: .normal)
        
        addFriendButton.isEnabled = false
        
        addFriendButton.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func tagSegmentChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            queryUserPosts()
            
        default:
            guard let tag = sender.titleForSegment(at: sender.selectedSegmentIndex) else { return }
            queryUserTagPosts(tag: tag)
        }
    }
    
    func getPosts() {
        
        switch tagSegment.selectedSegmentIndex {
            
        case 0:
            queryUserPosts()
            
        default:
            guard let tag = tagSegment.titleForSegment(at: tagSegment.selectedSegmentIndex) else { return }
            queryUserTagPosts(tag: tag)
        }
    }
    
    func queryUserPosts() {
        
        guard let email = emailLabel.text else { return }
        
        FirebaseManager.shared.queryPost(
            key: "author",
            value: email,
            success: { (result) in
                
                self.posts = result
                
                self.postTableView.reloadData()
                
            }, failure: { (error) in
            
                self.posts = []
            
                self.postTableView.reloadData()
        })
    }
    
    func queryUserTagPosts(tag: String) {
        
        guard let email = emailLabel.text else { return }
        
        FirebaseManager.shared.queryPost(
            key: "author_tag",
            value: email+tag,
            success: { (result) in
                
                self.posts = result
                
                self.postTableView.reloadData()
                
            }, failure: { (error) in
            
                self.posts = []
            
                self.postTableView.reloadData()
        })
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = postTableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
            ) as? PostTableViewCell
            else {
                return UITableViewCell()
        }
        
        cell.setPosts(post: posts[indexPath.row])
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {}
