//
//  LoginViewController.swift
//  Instagram
//
//  Created by Akio Chikai on 2016/04/27.
//  Copyright © 2016年 Akio Chikai. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    var firebaseRef: Firebase!
    
    // ログインボタンをタップした時に呼ばれるメソッド
    @IBAction func handleLoginButton(sender: AnyObject) {
        
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時はHUDを出して何もしない
            if address.characters.isEmpty || password.characters.isEmpty {
                SVProgressHUD.showErrorWithStatus("必要項目を入力して下さい")
                return
            }
            
            // 処理中を表示
            SVProgressHUD.show()
            
            firebaseRef.authUser(address, password: password, withCompletionBlock: { error, authData in
                if error != nil {
                    // エラー表示
                    SVProgressHUD.showErrorWithStatus("エラー")
                } else {
                    
                    // firebase からログインしたユーザの表示名を取得してNSUserDefaultsに保存する
                    let usersRef = self.firebaseRef.childByAppendingPath(CommonConst.UsersPATH)
                    let uidRef = usersRef.childByAppendingPath(authData.uid)
                    uidRef.observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                        
                        if let displayName = snapshot.value.objectForKey("name") as? String {
                            self.setDisplayName(displayName)
                        }
                        
                        // HUDを消す
                        SVProgressHUD.dismiss()
                        
                        // 画面を閉じる
                        self.dismissViewControllerAnimated(true, completion: nil)})
                }
                })
        }
    }
    
    @IBAction func handleCreateAcountButton(sender: AnyObject) {
        
        if let address = mailAddressTextField.text, let password = passwordTextField.text,
            let displayName = displayNameTextField.text {
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.characters.isEmpty || password.characters.isEmpty
                || displayName.characters.isEmpty {
                SVProgressHUD.showErrorWithStatus("必要項目を入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            firebaseRef.createUser(address, password: password, withValueCompletionBlock: { error, result in
                if error != nil {
                    SVProgressHUD.showErrorWithStatus("エラー")
                } else {
                    // ユーザーを作成できたらそのままログインする
                    self.firebaseRef.authUser(address, password: password, withCompletionBlock: { error, authData in
                        if error != nil {
                            SVProgressHUD.showErrorWithStatus("エラー")
                        } else {
                            // Firebase に表示名を保存する
                            let usersRef = self.firebaseRef.childByAppendingPath(CommonConst.UsersPATH)
                            let data = ["name": displayName]
                            usersRef.childByAppendingPath("/\(authData.uid)").setValue(data)
                            
                            // NSUserDefaults に表示名を保存する
                            self.setDisplayName(displayName)
                            
                            // HUDを消す
                            SVProgressHUD.dismiss()
                            
                            // 画面を閉じる
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                })
        }
    })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Firebase を初期化する
        firebaseRef = Firebase(url: CommonConst.FirebaseURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDisplayName(name: String) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setValue(name, forKey: CommonConst.DisplayNameKey)
        ud.synchronize()
    }
}
