//
//  Communicator.swift
//  MaPle
//
//  Created by Bron on 2018/11/21.
//

import Foundation
import Alamofire

//let email = "rian@gmail.com"
//let password = "Brian@gmail.com"
let userValid = "userValid"
let findByEP = "findByEP"
let insert = "insert"
let useraccount = "useraccount"

let MemberID_Key = "MemberID"
let Email_Key = "Email"
let PassWord_Key = "PassWord"
let UserName_Key = "UserName"
let DATA_KEY = "data"
let action_Key = "action"


typealias DoneHandler = (_ result:Int?, _ error:Error?) -> Void
typealias DoneMemberIdHandler = (_ result:Int?, _ error:Error?) -> Void
typealias DownloadDoneHandler = (_ result:Data?, _ error:Error?) -> Void

class  Communicator {
    
//    static let BASEURL = "http://192.168.0.137:8080/MaPle/"
    static let BASEURL = "http://192.168.196.156:8080/MaPle/"
    let Login_URL = BASEURL + "UserAccountServlet"
    let Spot_URL = BASEURL + "spotServlet"
    
    static let shared = Communicator()
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
    
    func findMemberId(Email:String, PassWord:String, completion: @escaping DoneMemberIdHandler) {
        let parameters = [action_Key:findByEP,
                          Email_Key:Email,
                          PassWord_Key:PassWord]

        dopostId(urlstring: Login_URL,
                 parameters: parameters,
                 completion: completion)

    }
    
    func register(Email:String, PassWord:String, completion: @escaping DoneMemberIdHandler) {
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
    
//    //MARK: - Public methods
//    func update(deviceToken:String, completion: @escaping DoneHandler) {
//        //
//        let parameters = [USERNAME_KEY:MY_NAME,
//                          DEVICETOKEN_KEY:deviceToken,
//                          GROUPNAME_KEY: GROUPNAME]
//        print(parameters)
//        dopost(urlstring: UPDATEDEVICETOKEN_URL,
//               parameters: parameters,
//               completion: completion)
//
//    }
//
//    func send(text message:String, completion: @escaping DoneHandler) {
//
//        let parameters = [USERNAME_KEY:MY_NAME,
//                          MESSAGE_KEY:message,
//                          GROUPNAME_KEY: GROUPNAME]
//
//        dopost(urlstring: SEND_MESSAGE_URL,
//               parameters: parameters,
//               completion: completion)
//
//    }
//
//    func retriveMessages(last messageID:Int, completion: @escaping DoneHandler) {
//
//        let parameters:[String:Any] = [LASTMESSAGE_ID_KEY:messageID,
//                                       GROUPNAME_KEY: GROUPNAME]
//        print(parameters)
//        dopost(urlstring: RETRIVE_MESSAGES_URL,parameters: parameters,completion: completion)
//
//    }
//
    func downloadPhoto(completion: @escaping DownloadDoneHandler){
        let finalURLString = Spot_URL
        Alamofire.request(finalURLString).responseData { (response) in
            switch response.result{
            case .success(let data):
                print("photo Download OK: \(data.count)")
                completion(data, nil)
            case .failure(let error):
                print("photo Download Fail: \(error)")
                completion(nil, error)
            }
        }
        //        let data = try? Data(contentsOf: url)     UI thread會卡住等下載完畢才往下跑
    }

//    func send(photoMessage data:Data, completion: @escaping DoneHandler) {
//        let parameters = [USERNAME_KEY:MY_NAME,
//                          GROUPNAME_KEY: GROUPNAME]
//
//        dopost(urlstring: SEND_PHOTOMESSAGE_URL,
//               parameters: parameters,
//               data: data,
//               completion: completion)
//    }

//    private func dopost(urlstring:String ,
//                        parameters:[String:Any],
//                        data:Data,
//                        completion:@escaping DoneHandler){
//        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//        Alamofire.upload(multipartFormData: { (formData) in
//            //透過formData組織一個DATA
//            formData.append(jsonData, withName: DATA_KEY)
//            //分別帶入 上傳的資料,來源,檔案名稱,上傳的檔案型態
//            formData.append(data, withName: "fileToUpload", fileName: "image.jpg", mimeType: "image/jpg")
//        }, to: urlstring, method: .post) { (encodingResult) in
//            //encodingResult 資料未出去,先處理encoding的成功或失敗的結果
//            switch encodingResult{
//                //                case .success(let request, let fromDisk, let url): 同下
//            //成功的話後面兩欄可省略
//            case .success(let request, _, _):
//                print("Post Encoding OK")
//                //                request.responseJSON(completionHandler: <#T##(DataResponse<Any>) -> Void#>) 同下
//                request.responseJSON { (response) in
//                    self.handleJSON(response: response, completion: completion)
//                }
//            case .failure(let error):
//                print("Post Encoding fail: \(error)")
//                completion(nil, error)
//            }
//        }
//    }
    
//    private func dopost(urlstring:String ,
//                        parameters:[String:Any],
//                        completion:@escaping DoneHandler){
//
//        Alamofire.request(urlstring, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
//
//            self.handleMemberID(response: response, completion: completion)
//        }
//    }

    private func dopost(urlstring:String ,
                        parameters:[String:Any],
                        completion:@escaping DoneHandler){

        Alamofire.request(urlstring, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in

            self.handleJSON(response: response, completion: completion)
        }
    }
    
    private func dopostId(urlstring:String ,
                        parameters:[String:Any],
                        completion:@escaping DoneMemberIdHandler){
        
        Alamofire.request(urlstring, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            
            self.handleMemberID(response: response, completion: completion)
        }
    }
    
//    private func dopostregister(urlstring:String ,
//                          parameters:[String:Any],
//                          completion:@escaping DoneMemberIdHandler){
//
//        Alamofire.request(urlstring, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
//
//            self.handleMemberID(response: response, completion: completion)
//        }
//    }
    
    private func handleJSON(response:DataResponse<Any>,
                            completion: DoneHandler) {
        switch response.result{
        // 如果是success宣告為json
        case.success(let json):
            let result = json as? Int
//            print("\(String(describing: result))")
            let error = NSError(domain: "Invalid JSON object", code: -1, userInfo: nil)
            if result == 1 {
//                let finalJson = json as? [String: Any]
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
    
    private func handleMemberID(response:DataResponse<Any>,
                            completion: DoneMemberIdHandler) {
        switch response.result{
        // 如果是success宣告為json
        case.success(let json):
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
    
   
}


