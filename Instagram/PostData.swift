//
//  PostData.swift
//  Instagram
//
//  Created by Akio Chikai on 2016/04/28.
//  Copyright © 2016年 Akio Chikai. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String?
    var image: UIImage?
    var imageString: String?
    var name: String?
    var caption: String?
    var date: NSDate?
    var likes: [String] = []
    var isLiked: Bool = false
    var comment: [String] = []
    var commentator: [String] = []
    var commentatorComment: [String] = []
    
    init(snapshot: FDataSnapshot, myId: String) {
        id = snapshot.key
        
        imageString = snapshot.value.objectForKey("image") as? String
        image = UIImage(data: NSData(base64EncodedString: imageString!, options: .IgnoreUnknownCharacters)!)
        name = snapshot.value.objectForKey("name") as? String
        caption = snapshot.value.objectForKey("caption") as? String
        
        if let comment = snapshot.value.objectForKey("comment") as? [String] {
            self.comment = comment
        }
        
        if let commentator = snapshot.value.objectForKey("commentator") as? [String] {
            self.commentator = commentator
        }
        
        if let commentatorComment = snapshot.value.objectForKey("commentatorComment") as? [String] {
            self.commentatorComment = commentatorComment
        }
        
        if let likes = snapshot.value.objectForKey("likes") as? [String] {
            self.likes = likes
        }
        
        for likeId in likes {
            if likeId == myId {
                isLiked = true
                break
            }
        }
        
        self.date = NSDate(timeIntervalSinceReferenceDate: snapshot.value.objectForKey("time") as! NSTimeInterval)
    }
}
