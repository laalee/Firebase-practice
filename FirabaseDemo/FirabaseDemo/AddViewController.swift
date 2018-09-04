//
//  AddViewController.swift
//  FirabaseDemo
//
//  Created by HsinYuLi on 2018/9/4.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {
    
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var tagSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBorder()
    }

    @IBAction func postClick(_ sender: Any) {
        
        guard let title = titleTextView.text else { return }
        
        guard let content = contentTextView.text else { return }
        
        guard let tag = tagSegment.titleForSegment(at: tagSegment.selectedSegmentIndex) else { return }
        
        FirebaseManager.shared.addPost(title: title, content: content, tag: tag)
        
        titleTextView.text = ""
        
        contentTextView.text = ""
    }
    
    func setBorder() {
        
        titleTextView.layer.borderWidth = 1
        titleTextView.layer.borderColor = UIColor.lightGray.cgColor
        titleTextView.clipsToBounds = true
        titleTextView.layer.cornerRadius = 5
        
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.clipsToBounds = true
        contentTextView.layer.cornerRadius = 5
    }
    
}
