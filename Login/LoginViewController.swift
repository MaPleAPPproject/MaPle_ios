//
//  LoginViewController.swift
//  MaPle
//
//  Created by Bron on 2018/11/15.
//

import UIKit

class LoginViewController: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    var label:UITextField!
    var email = ""
    var passWord = ""
    var communicator = MapCommunicator.shared
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func LoginBtn(_ sender: Any) {
        email = accountTextField.text!
        passWord = passwordTextField.text!
        
        if email == "" || passWord == ""  {
            alert(message: "帳密不可為空白")
            return
        }
        communicator.login(Email: email, PassWord: passWord) { (data, error) in
            if let error = error {
                print("error:\(error)")
                self.alert(message: "帳密錯誤")
                return
            }
            self.communicator.findMemberId(Email: self.email, PassWord: self.passWord, completion: { (data, error) in
                if error != nil {
                    print("error:\(error!)")
                    self.alert(message: "伺服器連線異常")
                    return
                }else if data! == 0 {
                    self.alert(message: "無此使用者")
                    return
                }
                else {
                    let memberId = data! as Int
                    let stringMemberId = String(memberId)
                    self.userDefaults.set(memberId, forKey: "MemberIDint")
                    self.userDefaults.set(stringMemberId, forKey: "MemberID")
                    self.userDefaults.set(self.email, forKey: "Email")
                    self.userDefaults.set(self.passWord, forKey: "PassWord")
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "registerView")
                    self.show(vc!, sender: self)
                }
            })
        }
    }
    
    @IBAction func registerBtn(_ sender: Any) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 結束編輯 把鍵盤隱藏起來
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func beginEdit(_ sender: UITextField) {
        animateViewMoving(up: true, moveValue: 100)
    }
    
    @IBAction func endEdit(_ sender: UITextField) {
        animateViewMoving(up: false, moveValue: 100)
    }
    
    //textField movement method
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    func alert(message:String) {
        let alert = UIAlertController(title: "警告!", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
            action in
        })
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
