//
//  PostViewCell.swift
//  Social-Networking
//
//  Created by macos on 8/6/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit
import Firebase

class PostViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    
    var post: PostModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(post: PostModel, img: UIImage? = nil) {
        self.post = post
        self.caption.text = post.caption
        self.likesLabel.text = "\(post.likes)"
        
        if img != nil {
            self.postImg.image = img
        } else {
            let ref = Storage.storage().reference(forURL: post.imageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("Jess: Unable to download image from firebase storage")
                } else {
                    print("Jess: Image downloaded from firebase storgae")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedViewController.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
    }
}
