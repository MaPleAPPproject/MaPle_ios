//
//  Commuicator.swift
//  ChatRoom
//
//  Created by Violet on 2018/10/24.
//  Copyright © 2018 Violet. All rights reserved.
//

import Foundation
import Alamofire




class ExploreCommunicator {
    let ACTION_KEY = "action"
    
    
    typealias ArrayDoneHandler = (_ result:[Any]?, _ error: Error?) -> Void //json回傳結果放置result
    typealias AnyDoneHandler = (_ result:Any?, _ error: Error?) -> Void //json回傳結果放置result
    
    typealias DataDoneHandler = (_ result:Data?, _ error: Error?) -> Void //json回傳結果為data
    
    static let BASEURL = "http://192.168.50.224:8080/MaPle/"
    let PictureServlet_URL = BASEURL + "PictureServlet"
    let UserProfileServlet_URL = BASEURL + "User_profileServlet"
    let UserPreferenceServlet_URL = BASEURL + "UserPreferenceServlet"
    let PostDetailServlet_URL = BASEURL + "PostDetailServlet"
    let LocationListServlet = BASEURL + "LocationListServlet"


    
    static let shared = ExploreCommunicator()
    private init() {
        
    }
    

//    MARK: - PictureServlet Public methods.
    func getDistinct( completion: @escaping AnyDoneHandler ) {

        let parameters = [ACTION_KEY: "getDistinct"]
        doPost(urlString: PictureServlet_URL, parameters: parameters, completion: completion)//執行Post
    }
    func getImage(postId: String, completion: @escaping DataDoneHandler) {
        let parameters = [ACTION_KEY: "getImage", "postid": postId ]
        Alamofire.request(PictureServlet_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { (response) in //回傳Data
            switch response.result {
            case .success(let data):
                print("image download Ok:\(data.count) bytes")
                completion(data, nil)
            case .failure(let error):
                print("image download fail:\(error)")
                completion(nil,error)
            }
        }

    }
    
    func getAllPost(memberid: String, completion: @escaping ArrayDoneHandler) {
        let parameters = [ACTION_KEY: "getBymemberId", "memberid": memberid ]
        doPost(urlString: PictureServlet_URL, parameters: parameters, arrayCompletion: completion)
    }
    
    func getAllCollect(memberid: String, completion: @escaping ArrayDoneHandler) {
        let parameters = [ACTION_KEY: "getcollectBymemberId", "memberid": memberid ]
        doPost(urlString: PictureServlet_URL, parameters: parameters, arrayCompletion: completion)
    }
    
    func getAll( completion: @escaping ArrayDoneHandler) {
        let parameters = [ACTION_KEY: "getAll"]
        doPost(urlString: PictureServlet_URL, parameters: parameters, arrayCompletion: completion)
    }
    func getRecom(memberid: String, completion: @escaping ArrayDoneHandler) {
        let parameters = [ACTION_KEY: "getRecom", "memberid": memberid ]
        doPost(urlString: PictureServlet_URL, parameters: parameters, arrayCompletion: completion)
    }
    func getTop( completion: @escaping ArrayDoneHandler) {
        
        let parameters = ["action":"getTop"]
        doPost(urlString: PictureServlet_URL, parameters: parameters, arrayCompletion: completion)
    }
    
    //MARK: - User_ProfileServlet Public methods.

    func getIcon(memberId: String, imageSize: String, completion: @escaping DataDoneHandler) {
        let parameters = [ACTION_KEY: "getImage", "memberId": memberId, "imageSize": imageSize]
        Alamofire.request(UserProfileServlet_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { (response) in //回傳Data
            switch response.result {
            case .success(let data):
//                print("image download Ok:\(data.count) bytes")
                completion(data, nil)
            case .failure(let error):
                print("image download fail:\(error)")
                completion(nil,error)
            }
        }
    }
    func getProfile(memberId: String, completion: @escaping AnyDoneHandler) {
        let parameters = [ACTION_KEY: "findotherById", "memberId": memberId]
        doPost(urlString: UserProfileServlet_URL, parameters: parameters, completion: completion)
    }
    //MARK: - PostDetailServlet Public methods.
    func getPostdetail(postId: String, completion: @escaping AnyDoneHandler) {
        let parameters = [ACTION_KEY: "findById", "postid": postId]
        doPost(urlString: PostDetailServlet_URL, parameters: parameters, completion: completion)
    }
    
    //MARK: - LocationListServlet Public methods.
    func getLocationList(postId: String, completion: @escaping AnyDoneHandler) {
        let parameters = [ACTION_KEY: "findById", "PostId": postId]
        doPost(urlString: LocationListServlet, parameters: parameters, completion: completion)
    }
    
    //MARK: - UserPreferenceServlet Public methods.
    func addCollect(userPreference: UserPreference, completion: @escaping AnyDoneHandler) {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(userPreference)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)!
        let parameters = [ACTION_KEY: "userpreInsert","userpe": json]
        doPost(urlString: UserPreferenceServlet_URL, parameters: parameters, completion: completion)
    }
    
    func cancelCollect(postId: String, collectorId: String, completion: @escaping AnyDoneHandler) {
        let parameters = [ACTION_KEY: "userpreDelete", "postid": postId, "collectorid": collectorId]
        doPost(urlString: UserPreferenceServlet_URL, parameters: parameters, completion: completion)
    }
    
    func isCollectable(postId: String, collectorId: String, completion: @escaping AnyDoneHandler) {
        let parameters = [ACTION_KEY: "userValid", "postid": postId, "collectorid": collectorId]
        doPost(urlString: UserPreferenceServlet_URL, parameters: parameters, completion: completion)
    }

    
//   private func doPost(urlString: String, parameters: [String: Any], completion: @escaping DoneHandler) {
//
//        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in
//            self.handleJSON(response: response, completion: completion)
//        }
//    }
    private func doPost(urlString: String, parameters: [String: Any], completion: @escaping AnyDoneHandler) {

        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            self.handleJSON(response: response, completion: completion)
        }
    }
    
    private func doPost(urlString: String, parameters: [String: Any], arrayCompletion: @escaping ArrayDoneHandler) {
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            self.handleJSON(response: response, completion: arrayCompletion)
        }
    }
    
    private func handleJSON(response: DataResponse<Any>, completion: AnyDoneHandler) {
        switch response.result {
            case .success(let json)://result enum 特殊型態 可以讓參數夾帶另一個結果
                print("get success response:\(json)")
                guard let finaljson = json as? Any else {//因為回傳型別為Any 所以要轉型成字串
                    let error = NSError(domain: "Invaild JSON object", code: -1, userInfo: nil)
                    completion(nil, error)
                    return
                }
                completion(finaljson, nil)
            
            case .failure(let error):
                print("Server response error:\(error)")
                completion(nil,error)
        }
    }
    private func handleJSON(response: DataResponse<Any>, completion: ArrayDoneHandler) {
        switch response.result {
        case .success(let json)://result enum 特殊型態 可以讓參數夾帶另一個結果
            print("get success response:\(json)")
            guard let finaljson = json as? [Any] else {//因為回傳型別為Any 所以要轉型成字串
                let error = NSError(domain: "Invaild JSON object", code: -1, userInfo: nil)
                completion(nil, error)
                return
            }
            completion(finaljson, nil)
            
        case .failure(let error):
            print("Server response error:\(error)")
            completion(nil,error)
        }
    }
}



