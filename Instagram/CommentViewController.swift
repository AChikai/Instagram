//
//  CommentViewController.swift
//  Instagram
//
//  Created by Akio Chikai on 2016/05/02.
//  Copyright © 2016年 Akio Chikai. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CommentViewController: UIViewController {
    
    //var commentImageView = UIImageView?()
    
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var commentTextLabel: UITextField?
    
    var postData: PostData?
    
    @IBAction func commentButton(sender: AnyObject) {
                
        if let postData = postData {
            
            let ud = NSUserDefaults.standardUserDefaults()
            var commentator = ud.objectForKey(CommonConst.DisplayNameKey) as! String
            
            let imageString = postData.imageString
            let name = postData.name
            let caption = postData.caption
            let time = (postData.date?.timeIntervalSinceReferenceDate)! as NSTimeInterval
            let likes = postData.likes
            //let comment: String? = commentTextLabel!.text
            var comment = postData.comment
            let commentSet = "\(commentator):\(commentTextLabel?.text!)"

            comment.append(commentSet)
            
            var commentatorComment = (commentator : comment)
            commentatorComment.append((commentTextLabel?.text!)!)
            
            //var commentator = postData.commentator
            //commentator.append(commentTextLabel!.text)
            
            //var commentatorComment = (commentator : comment)
            
            
            // 辞書を作成してFirebaseに保存する
            let post = ["caption": caption!, "image": imageString!, "name": name!, "time": time, "likes": likes, "comment": comment]
            let postRef = Firebase(url: CommonConst.FirebaseURL).childByAppendingPath(CommonConst.PostPATH)
            postRef.childByAppendingPath(postData.id).setValue(post)

//print(commentatorComment)
            

        }
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccessWithStatus("投稿しました")
        
        // 画面を閉じる
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // キャンセルボタンで画面を閉じる
    @IBAction func cancelButton(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        commentImage.image = appDelegate.senderImage
        postData = appDelegate.senderPostData
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
