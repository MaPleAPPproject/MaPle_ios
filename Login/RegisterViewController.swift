//
//  RegisterViewController.swift
//  MaPle
//
//  Created by Bron on 2018/11/15.
//

import UIKit

class RegisterViewController: UIViewController,UITextViewDelegate {

    var account = ""
    var passWord = ""
//    let account = ""
//    let passWord = ""
    var communicator = MapCommunicator.shared
    
    @IBOutlet weak var accountTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        account = accountTextField.text!
        passWord = passwordTextField.text!
        if self.account == "" || self.passWord == ""  {
            let alert = UIAlertController(title: "警告!", message: "帳號或密碼不可為空白", preferredStyle: .alert)
            let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                action in
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
            communicator.login(Email: account, PassWord: passWord) { (data, error) in
            let result = data
            if let error = error {
                print(error)
                let alert = UIAlertController(title: "警告!", message: "伺服器連線錯誤(1)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                    action in
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return
            }else if result == 1{
                let alert = UIAlertController(title: "警告!", message: "此帳號已經有人使用", preferredStyle: .alert)
                let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                    action in
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return
            }else if result == 0 {
                    self.communicator.register(Email: self.account, PassWord: self.passWord, completion: { (data, error) in
                        if let error = error {
                            print(error)
                            let alert = UIAlertController(title: "警告!", message: "伺服器連線異常(2)", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                                action in
                            })
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                            let alert = UIAlertController(title: "警告!", message: "帳號申請成功", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                                action in
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView")
                                self.show(vc!, sender: self)
                            })
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                            return
                })
            }
        }
    }
    @IBAction func backBtnPressed(_ sender: Any) {
    }
    
    @IBAction func beginEdit(_ sender: UITextField) {
        animateViewMoving(up: true, moveValue: 100)
    }
    
    @IBAction func endEdit(_ sender: UITextField) {
        animateViewMoving(up: false, moveValue: 100)
    }
    //位移View
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 結束編輯 把鍵盤隱藏起來
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
