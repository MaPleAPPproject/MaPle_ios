//
//  File.swift
//  FindMyFriendsExecrise
//
//  Created by Paul Chen on 2018/10/24.
//  Copyright © 2018 Team. All rights reserved.
//

import Foundation
import Alamofire

let url = "http://\(Communicator.IP):8080/MaPle"
let userProfileUrl = "\(url)/User_profileServlet"


class ServerCommunicator {
    
    var memberId: Int
    
    init(_ memberid : Int){
        self.memberId = memberid
    }
    //  MARK: - Public methods.
    
    
    typealias DoneHandler = (_ result:[String:Any]?, _ error: Error?) ->Void
    
    func loadUserVipStatus(completion: @escaping DoneHandler){
        let parameters = ["action":"findById", "memberId": "\(memberId)"]
        doPost(userProfileUrl, parameters,  completion: completion)
    }
    
    func updateUserVipStatus(_ userId: Int, completion: @escaping DoneHandler){
        let parameters = ["action":"vipStatusUpdate", "memberId": "\(memberId)"]
        doPost(userProfileUrl, parameters, completion: completion)
    }
    
    fileprivate func doPost(_ urlString:String, _ parameters:[String: Any],completion:@escaping DoneHandler) {
        
        
        Alamofire.request(userProfileUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default ).responseJSON { (response) in
            switch response.result {
                
            case .success(let json):
                print("Get success response: \(json)")
                
                guard let finalJson = json as? [String:Any] else {
                    let error = NSError(domain: "Invalid JSON object.", code: -1, userInfo: nil)
                    completion(nil, error)
                    return
                }
                
                completion(finalJson, nil)
                
            case .failure(let error):
                print("Get error response: \(error)")
                
                completion(nil, error)
            }
        }
    }
    
    
}





