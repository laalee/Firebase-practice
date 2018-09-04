//
//  PostTableViewCell.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/5.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setPosts(post: Post) {

        tagLabel.text = post.article_tag
        
        titleLabel.text = post.article_title
        
        nameLabel.text = post.author
        
        timeLabel.text = post.created_time
        
        contentLabel.text = post.article_content
    }
    
}
