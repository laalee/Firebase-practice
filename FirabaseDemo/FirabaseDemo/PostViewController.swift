//
//  PostViewController.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/5.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    
    @IBOutlet weak var tagSegment: UISegmentedControl!
    
    @IBOutlet weak var postTableView: UITableView!
    
    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.dataSource = self
        postTableView.delegate = self
        
        let uiNib = UINib(nibName: "PostTableViewCell", bundle: nil)
        postTableView.register(uiNib, forCellReuseIdentifier: "Cell")
        
        getPosts()
    }
    
    @IBAction func tagSegmentChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            getAllPosts()
            
        default:
            guard let tag = sender.titleForSegment(at: sender.selectedSegmentIndex) else { return }
            queryPosts(tag: tag)
        }
    }
    
    func getPosts() {
        
        switch tagSegment.selectedSegmentIndex {
            
        case 0:
            getAllPosts()
            
        default:
            guard let tag = tagSegment.titleForSegment(at: tagSegment.selectedSegmentIndex) else { return }
            queryPosts(tag: tag)
        }
    }
    
    func getAllPosts() {
        
        FirebaseManager.shared.getAllPosts(
            success: { (result) in
                
                self.posts = result
                
                self.postTableView.reloadData()
                
            }, failure: { (error) in
                
                self.posts = []
                
                self.postTableView.reloadData()
        })
    }
    
    func queryPosts(tag: String) {
        
        FirebaseManager.shared.queryPost(
            key: "article_tag",
            value: tag,
            success: { (result) in
                
                self.posts = result
                
                self.postTableView.reloadData()
                
            }, failure: { (error) in
                
                self.posts = []
                
                self.postTableView.reloadData()
        })
    }

}

extension PostViewController: UITableViewDataSource {
    
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

extension PostViewController: UITableViewDelegate {}
