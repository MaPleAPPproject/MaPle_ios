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
    
    var label:UITextField!
    var email = "abc@gmail.com"
    var passWord = "abc123"
    var communicator = MapCommunicator.shared
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func LoginBtn(_ sender: Any) {
//        email = accountTextField.text!
//        passWord = passwordTextField.text!

        communicator.login(Email: email, PassWord: passWord) { (data, error) in
            if let error = error {
                print(error)
                let alert = UIAlertController(title: "警告!", message: "帳密錯誤", preferredStyle: .alert)
                let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                    action in
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.communicator.findMemberId(Email: self.email, PassWord: self.passWord, completion: { (data, error) in
                let memberId = data! as Int
                let stringMemberId = String(memberId)
                self.userDefaults.set(stringMemberId, forKey: "MemberID")
                self.userDefaults.set(self.email, forKey: "Email")
                self.userDefaults.set(self.passWord, forKey: "PassWord")
            })
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "registerView")
            self.show(vc!, sender: self)
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
  
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//    func getUserList(Email:String,PassWord:String) -> Bool {
//        var result = false
////        let url = URL(string:"http://192.168.50.90:8080/MaPle/Login/Post")
//        let url = URL(string:"http://192.168.0.137:8080/MaPle/UserAccountServlet?Email=\(Email)?PassWord=\(PassWord)?action=userValid")
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config)
//        let dnTask = session.dataTask(with: url!) {(data,response,error) in
//            print(data as Any)
//            guard let data = data,error == nil else{
//                print("data error")
//                return
//            }
//            guard let userAccount = try? JSONDecoder().decode(UserAccount.self , from: data) else {
//                print("decode error")
//                return
//            }
//            print(userAccount)
//        }
//        dnTask.resume()
//        result = true
//        return result
//    }
    
//    func requestWithJSONBody(urlString: String, parameters: [String: Any], completion: @escaping (Data) -> Void){
//        let url = URL(string: urlString)!
//        var request = URLRequest(url: url)
//
//        do{
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
//        }catch let error{
//            print(error)
//        }
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        fetchedDataByDataTask(from: request, completion: completion)
//    }
//    private func fetchedDataByDataTask(from request: URLRequest, completion: @escaping (Data) -> Void){
//
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//
//            if error != nil{
//                print(error as Any)
//            }else{
//                guard let data = data else{return}
//                completion(data)
//            }
//        }
//        task.resume()
//    }
}
