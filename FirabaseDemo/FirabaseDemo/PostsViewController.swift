//
//  PostsViewController.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/5.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit

class PostsViewController: UIViewController {
    
    @IBOutlet weak var tagSegment: UISegmentedControl!
    
    @IBOutlet weak var postTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tagSegmentChanged(_ sender: UISegmentedControl) {
    }

}
