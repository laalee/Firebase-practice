//
//  ProfileViewController.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/4.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var friendTableView: UITableView!
        
    var friends: [Member]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendTableView.dataSource = self
        friendTableView.delegate = self
        
        let uiNib = UINib(nibName: "FriendTableViewCell", bundle: nil)
        friendTableView.register(uiNib, forCellReuseIdentifier: "Cell")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFriendList(notification:)),
            name: NSNotification.Name("UPDATE_FRIEND"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setProfile()
        
        gatFriends()
    }
    
    @objc func updateFriendList(notification: Notification) {
        
        gatFriends()
    }
    
    func setProfile() {
        
        guard let userKey = UserManager.shared.getUserKey() else{ return }
        
        FirebaseManager.shared.searchMember(
            userKey: userKey,
            success: { (key, name, email) in
                self.nameLabel.text = name
                self.emailLabel.text = email
            },
            failure: {_ in
                print("faillllll")
        })
    }
    
    func gatFriends() {
        
        friends = []
        
        getFriends(tag: "valid")
        
        getFriends(tag: "pending_send")
        
        getFriends(tag: "pending_confirm")
        
        friendTableView.reloadData()
    }

    func getFriends(tag: String) {
        FirebaseManager.shared.getFriends(
            tag: tag,
            success: { (id, name, email) in
                
                let member = Member(id: id, name: name, email: email, invite_status: tag)
                
                self.friends?.append(member)
            },
            failure: {
                
                print("tag(\(tag)) is nil.")
            },
            complete: {
                
                self.friendTableView.reloadData()
        })
    }
    
    @objc func yesButtonClicked(sender: UIButton) {
        
        print("yesssss")
        
        guard let id = friends?[sender.tag].id else { return }
        
        FirebaseManager.shared.confirmFriend(friendkey: id)
    }
    
    @objc func noButtonClicked(sender: UIButton) {
        
        print("nooooo")
        
        guard let id = friends?[sender.tag].id else { return }
        
        FirebaseManager.shared.deleteFriend(friendkey: id)
    }

}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = friends?.count else {
            return 0
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = friendTableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
            ) as? FriendTableViewCell
            else {
                return UITableViewCell()
        }
        
        guard let friend = friends?[indexPath.row] else {
            return cell
        }
        
        cell.nameLabel.text = friend.name
        
        switch friend.invite_status {
        case "valid":
            cell.yesButton.isHidden = true
            cell.noButton.isEnabled = false
            cell.noButton.setTitle("好友", for: .normal)
        case "pending_send":
            cell.yesButton.isHidden = false
            cell.yesButton.isEnabled = false
            cell.noButton.isEnabled = true
            cell.yesButton.backgroundColor = UIColor.gray
            cell.yesButton.setTitle("已邀請", for: .normal)
            cell.noButton.setTitle("取消邀請", for: .normal)
        case "pending_confirm":
            cell.yesButton.isHidden = false
            cell.noButton.isHidden = false
            cell.yesButton.isEnabled = true
            cell.noButton.isEnabled = true
            cell.yesButton.backgroundColor = UIColor.black
            cell.yesButton.setTitle("待接受", for: .normal)
            cell.noButton.setTitle("拒絕", for: .normal)
        default:
            break
        }

        cell.yesButton.tag = indexPath.row
        
        cell.yesButton.addTarget(
            self,
            action: #selector(yesButtonClicked(sender:)),
            for: .touchUpInside
        )
        
        cell.noButton.addTarget(
            self,
            action: #selector(noButtonClicked(sender:)),
            for: .touchUpInside
        )
        
        return cell
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
}
