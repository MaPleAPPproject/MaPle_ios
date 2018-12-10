//
//  FriendCommunicator.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/11/21.
//

import Foundation
import Alamofire

let ACTION_KEY = "action"
let MEMBERID_KEY = "memberid"
let FRIENDID_KEY = "friendid"
let GETALL_KEY = "getAll"
let GETALLINVITE_KEY = "getAllinvite"
let REJECT_KEY = "friendReject"
let INVITELIKE_KEY = "findByIds2"
let MATCHLIKE_KEY = "findByIds"
let GETPHOTO_KEY = "getfriendImage"
let RESULT_KEY = "result"

//文字
typealias DoneHandler = (_ result: Any? , _ error: Error?) -> Void
//圖
typealias DownloadDoneHandler = (_ result: Data?, _ error: Error?) -> Void

class FriendCommunicator {
    static let BASEURL = "http://172.20.10.5:8080/MaPle"
    //"http://192.168.1.28:8080/MaPle" home
    //"http://192.168.196.147:8080/MaPle" Tibame
    let FRIENDLIST_URL = BASEURL + "/FriendServlet"
    let MATCH_URL = BASEURL + "/MatchServlet"
    let INVITE_URL = BASEURL + "/User_profileServlet"
    
    static let shared = FriendCommunicator()
    private init(){}
    
    func getAllFriend(memberid: Int, completion: @escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY : GETALL_KEY, "memberid" : memberid]
        doPost(url: FRIENDLIST_URL, parameters: parameters, completion: completion)
        print("getAllFriend parameters:\(parameters)")
    }
    
    func getAllInvitation(memberid: Int, completion: @escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY : GETALLINVITE_KEY, "memberid" : memberid]
        doPost(url: MATCH_URL, parameters: parameters, completion: completion)
        print("getAllInvitation parameters:\(parameters)")
    }
    
    func getAllMatch(memberid: Int, completion: @escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY : GETALL_KEY, "memberid" : memberid]
        doPost(url: MATCH_URL, parameters: parameters, completion: completion)
        print("getAllMatch parameters:\(parameters)")
    }
    
    func reject(memberid: Int, friendid:Int, completion: @escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY : REJECT_KEY, "memberid" : memberid, "friendid" : friendid]
        doPost(url: MATCH_URL, parameters: parameters, completion: completion)
        print("reject parameters:\(parameters)")
    }
    
    func acceptInvitation(memberid: Int, friendid:Int, completion: @escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY : INVITELIKE_KEY, "memberid" : friendid, "friendid" : memberid]
        doPost(url: MATCH_URL, parameters: parameters, completion: completion)
        print("acceptInvitation parameters:\(parameters)")
    }
    
    func acceptMatch(memberid: Int, friendid:Int, completion: @escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY : MATCHLIKE_KEY, "memberid" : memberid, "friendid" : friendid]
        doPost(url: MATCH_URL, parameters: parameters, completion: completion)
        print("acceptMatch parameters:\(parameters)")
    }
    
    func friendProfile(memberid: Int, completion: @escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY : REJECT_KEY, "MEMBERID_KEY" : memberid]
        doPost(url: MATCH_URL, parameters: parameters, completion: completion)
        print("friendProfile parameters:\(parameters)")
    }
    
    func getPhoto(id: Int, completion: @escaping DownloadDoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY : GETPHOTO_KEY, "id" : id,"imageSize" : 100]
        Alamofire.request(FRIENDLIST_URL, method: .post, parameters:parameters , encoding: JSONEncoding.default).responseData { (response) in
            switch response.result {
            case .success(let data):
                print("Photo Download OK: \(data.count) bytes",data.count)
                completion(data,nil)
            case .failure(let error):
                print("Photo Download Fail: \(error)")
                completion(nil, error)
            }
        }
        
    }
    
    func doPost(url: String, parameters:[String : Any]?, completion: @escaping DoneHandler ){
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
            self.handleJson(response: response, completion: completion)
        })
        
    }
    
    func handleJson(response: DataResponse<Any>, completion: DoneHandler) {
        
        print("response:\(response)")
        switch response.result {
            
        case .success(let json):
            print("Get success response: \(json)")
            completion(json,nil)
            
        case .failure( let error):
            print("Server respond error:\(error)")
            completion(nil, error)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
