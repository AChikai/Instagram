//
//  HomeViewController.swift
//  Instagram
//
//  Created by Akio Chikai on 2016/04/27.
//  Copyright © 2016年 Akio Chikai. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var firebaseRef:Firebase!
    var postArray: [PostData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UITableViewを準備する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Firebaseの準備をする
        firebaseRef = Firebase(url: CommonConst.FirebaseURL)
        
        // 要素が追加されたらpostArrayに追加してTableViewを再表示する
        firebaseRef.childByAppendingPath(CommonConst.PostPATH).observeEventType(FEventType.ChildAdded, withBlock: { snapshot in
            
            // PostDataクラスを生成して受け取ったデータを設定する
            let postData = PostData(snapshot: snapshot, myId: self.firebaseRef.authData.uid)
            self.postArray.insert(postData, atIndex: 0)
            
            // TableViewを再表示する
            self.tableView.reloadData()
    })
        // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
        firebaseRef.childByAppendingPath(CommonConst.PostPATH).observeEventType(FEventType.ChildChanged, withBlock: { snapshot in
            
            // PostDataクラスを生成して受け取ったデータを設定する
            let postData = PostData(snapshot: snapshot, myId: self.firebaseRef.authData.uid)
            
            // 保持している配列からidが同じものを探す
            var index: Int = 0
            for post in self.postArray {
                if post.id == postData.id {
                    index = self.postArray.indexOf(post)!
                    break
                }
            }
            
            // 差し替えるため一度削除する
            self.postArray.removeAtIndex(index)
            
            // 削除したところに更新済みのデータを追加する
            self.postArray.insert(postData, atIndex: index)
            
            // TableViewの該当セルだけを更新する
            //let indexPath = NSIndexPath(forRow: index, inSection: 0)
            //self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            self.tableView.reloadData()            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostTableViewCell
        cell.postData = postArray[indexPath.row]
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action: "handleButton:event:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // セル内のコメントボタンのアクションを設定
        cell.commentButton.addTarget(self, action: "handleCommentButton:event:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // UILabelの行数が変わっている可能性があるので再描画させる
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Auto Layaoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    // セルのボタンがタップされた時に呼ばれるメソッド
    func handleButton(sender: UIButton, event: UIEvent) {
        
        // タップされた時のインデックスを求める
        let touch = event.allTouches()?.first
        let point = touch!.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        let uid = firebaseRef.authData.uid
        
        if postData.isLiked {
            // すでにいいねをしていた場合はいいねを解除するためにIDを取り除く
            var index = -1
            for likeId in postData.likes {
                if likeId == uid {
                    // 解除するためにインデックスを保持しておく
                    index = postData.likes.indexOf(likeId)!
                    break
                }
            }
            postData.likes.removeAtIndex(index)
        } else {
            postData.likes.append(uid)
        }
        
        let imageString = postData.imageString
        let name = postData.name
        let caption = postData.caption
        let time = (postData.date?.timeIntervalSinceReferenceDate)! as NSTimeInterval
        let likes = postData.likes
        let comment = postData.comment
        let commentator = postData.commentator
        
        // 辞書を作成してFirebaseに保存する
        let post = ["caption": caption!, "image": imageString!, "name": name!, "time": time, "likes": likes, "comment": comment, "commentator": commentator]
        let postRef = Firebase(url: CommonConst.FirebaseURL).childByAppendingPath(CommonConst.PostPATH)
        postRef.childByAppendingPath(postData.id).setValue(post)

    }
    
    // セルのコメントボタンがタップされた時に呼ばれるメソッド
    func handleCommentButton(sender: UIButton, event: UIEvent) {
        
        // タップされた時のインデックスを求める
        let touch = event.allTouches()?.first
        let point = touch!.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        //let uid = firebaseRef.authData.uid
        

        
        //　遷移させる画像の準備
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.senderImage = postData.image
        appDelegate.senderPostData = postData
        
        // 遷移するメソッド
        let commentViewController: CommentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Comment") as! CommentViewController
        self.presentViewController(commentViewController, animated: true, completion: nil)
        // 辞書を作成してFirebaseに保存する
        // 再描写
        //self.tableView.reloadData()
    }
}
