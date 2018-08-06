//
//  FeedVC.swift
//  Social-Networking
//
//  Created by macos on 8/2/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var imageAdd: UIImageView!
    var posts = [PostModel]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        DataService.db.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("Snap: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = PostModel(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableview.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableview.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostViewCell {
            if let img = FeedViewController.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configure(post: post, img: img)
                return cell
            } else {
                cell.configure(post: post, img: nil)
                return cell
            }
        } else {
            return PostViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    @objc private func imagePickerControllerDidCancel(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
        } else {
            print("Jess: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postImage(_ sender: Any) {
        guard let caption = captionTextField.text, caption != "" else {
            print("Jess: caption must be entered")
            return
        }
        guard let img = imageAdd.image else {
            print("Jess: an image must be selected")
            return
        }
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.db.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Jess: Unable to upload image to firebase torage")
                } else {
                    print("Jess: successfully uploaded image to firebase storage")
//                    let downloadURL = metadata?.downloadURL()?.absoluteString
                }
            }
        }
    }
    
    @IBOutlet weak var tableview: UITableView!
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutBtn(_ sender: Any) {
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
}
