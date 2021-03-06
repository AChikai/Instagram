//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by Akio Chikai on 2016/04/28.
//  Copyright © 2016年 Akio Chikai. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

        @IBOutlet weak var postImageView: UIImageView!
        @IBOutlet weak var dateLabel: UILabel!
        @IBOutlet weak var captionLabel: UILabel!
        @IBOutlet weak var likeLabel: UILabel!
        @IBOutlet weak var likeButton: UIButton!
        @IBOutlet weak var commentLabel: UILabel?
        @IBOutlet weak var commentButton: UIButton!
    
        var postData: PostData?
    
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 表示されるときに呼ばれるメソッドをオーバーライドしてデータをUIに反映する
    override func layoutSubviews() {
        postImageView.image = postData!.image
        captionLabel.text = "\(postData!.name!) : \(postData!.caption!)"
              
        if ((postData?.comment) == nil) {
            commentLabel?.text = "コメント欄"
        } else {
            //let commentatorComent = postData!.commentatorComment
            //commentLabel!.text = "commentatorComent".joinWithSeparator("\n ")
            let commentator = postData!.name ?? ""
            let comment = postData!.comment.joinWithSeparator("\n ")
            commentLabel?.text = "\(commentator) : \(comment)"//.joinWithSeparator("\n ")
            
        }
        
        
        let likeNumber = postData!.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(postData!.date!)
        dateLabel.text = dateString
        
        if postData!.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            likeButton.setImage(buttonImage, forState: UIControlState.Normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            likeButton.setImage(buttonImage, forState: UIControlState.Normal)
        }
        super.layoutSubviews()
    }
    
}
