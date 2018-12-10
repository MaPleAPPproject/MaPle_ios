//
//  Communicator.swift
//  MaPle
//
//  Created by Bron on 2018/11/21.
//

import Foundation
import Alamofire

let userValid = "userValid"
let findByEP = "findByEP"
let findById = "findById"
let insert = "insert"
let useraccount = "useraccount"

let MemberID_Key = "MemberID"
let MemberId_Key = "MemberId"
let PostId_Key = "PostId"
let Email_Key = "Email"
let PassWord_Key = "PassWord"
let UserName_Key = "UserName"
let DATA_KEY = "data"
let action_Key = "action"
let imageSize_key = "imageSize"


typealias DownloadDoneHandler = (_ result:Data?, _ error:Error?) -> Void
typealias DoneHandler = (_ result:Int?, _ error:Error?) -> Void
typealias DoneMemberIdHandler = (_ result:String?, _ error:Error?) -> Void

class  MapCommunicator {
    
    static let BASEURL = "http://\(Communicator.IP):8080/MaPle"
    let Login_URL = BASEURL + "/UserAccountServlet"
    let spot_URL = BASEURL + "/spotServlet"
    
    static let shared = MapCommunicator()
    private init() {
        
    }
    
    func login(Email:String, PassWord:String, completion: @escaping DoneHandler) {
        let parameters = [action_Key:userValid,
                          Email_Key:Email,
                          PassWord_Key:PassWord]
        
        dopost(urlstring: Login_URL,
               parameters: parameters,
               completion: completion)
        
    }
    
    func findMemberId(Email:String, PassWord:String, completion: @escaping DoneHandler) {
        let parameters = [action_Key:findByEP,
                          Email_Key:Email,
                          PassWord_Key:PassWord]
        
        dopostId(urlstring: Login_URL,
                 parameters: parameters,
                 completion: completion)
        
    }
    
    func register(Email:String, PassWord:String, completion: @escaping DoneHandler) {
        let userData = ["Email":"\(Email)","PassWord":"\(PassWord)"]
        let jsonData = try! JSONSerialization.data(withJSONObject: userData, options: .prettyPrinted)
        print("\(jsonData)")
        //將data反轉回字串,並編碼為utf8
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)
        
        let parameters = [action_Key:insert,
                          useraccount: jsonString]
        
        dopostId(urlstring: Login_URL,
                 parameters: parameters,
                 completion: completion)
        
    }
    
    func findById(MemberId:String, completion: @escaping DoneMemberIdHandler) {
        
        let parameters = [action_Key: "findById",
                          MemberId_Key: MemberId] as [String : Any]
        
        dopostId(urlstring: spot_URL, parameters: parameters, completion: completion)
        
    }
    
    func findPhoto(PostId:Int, completion: @escaping DownloadDoneHandler) {
        
        let parameters = [action_Key: "getImage",
                          PostId_Key: PostId,
                          imageSize_key: 270 ] as [String : Any]
        
        dopostId(urlstring: spot_URL, parameters: parameters, completion: completion)
        
    }
    
    private func dopost(urlstring:String ,
                        parameters:[String:Any],
                        completion:@escaping DoneHandler){
        
        Alamofire.request(urlstring, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            
            self.handleJSON(response: response, completion: completion)
        }
    }
    
    private func dopostId(urlstring:String ,
                          parameters:[String:Any],
                          completion:@escaping DoneHandler){
        
        Alamofire.request(urlstring, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            
            self.handleMemberId(response: response, completion: completion)
        }
    }
    
    private func dopostId(urlstring:String ,
                          parameters:[String:Any],
                          completion:@escaping DoneMemberIdHandler){
        
        
        
        Alamofire.request(urlstring, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            
            self.handleUserList(response: response, completion: completion)
        }
    }
    
    private func dopostId(urlstring:String ,
                          parameters:[String:Any],
                          completion:@escaping DownloadDoneHandler){
        
        Alamofire.request(urlstring, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { (response) in
            
            self.handleJSONData(response: response, completion: completion)
        }
    }
    
    private func handleJSON(response:DataResponse<Any>,
                            completion: DoneHandler) {
        switch response.result{
        // 如果是success宣告為json
        case.success(let json):
            let result = json as? Int
            let error = NSError(domain: "Invalid JSON object", code: -1, userInfo: nil)
            if result == 1 {
                completion(result, nil)
            }else if result == 0{
                completion(result, nil)
            }else {
                print("Server respond error: ")
                completion(nil, error)
            }
            
        case.failure(let error):
            print("Server respond error: \(error)")
            completion(nil, error)
        }
    }
    
    private func handleMemberId(response:DataResponse<Any>,
                                completion: DoneHandler) {
        switch response.result{
        // 如果是success宣告為json
        case.success(let json):
            print("\(json)")
            let result = json as? Int
            let error = NSError(domain: "Invalid JSON object", code: -1, userInfo: nil)
            if result != nil {
                completion(result, nil)
            }else {
                print("Server respond error: ")
                completion(nil, error)
            }
            
        case.failure(let error):
            print("Server respond error: \(error)")
            completion(nil, error)
        }
    }
    
    private func handleUserList(response:DataResponse<Any>,
                                completion: DoneMemberIdHandler) {
        switch response.result{
        // 如果是success宣告為json
        case.success(let json):
            let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            //將data反轉回字串,並編碼為utf8
            let jsonString = String(data: jsonData, encoding: .utf8)!
            completion(jsonString, nil)
        case.failure(let error):
            print("Server respond error: \(error)")
            completion(nil, error)
        }
    }
    
    private func handleJSONData(response:DataResponse<Data>,
                                completion: DownloadDoneHandler) {
        
        switch response.result{
        // 如果是success宣告為json
        case.success(let json):
            print("success")
            completion(json, nil)
        case.failure(let error):
            print("Server respond error: \(error)")
            completion(nil, error)
        }
    }
}


