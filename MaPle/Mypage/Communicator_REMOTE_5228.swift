//
//  Communicator.swift
//  MaPle
//
//  Created by juiying chiu on 2018/11/19.
//

import Foundation
import Alamofire






class Communicator {
    
    static let IP = "192.168.50.213"
    
    static let BASEURL = "http://\(IP):8080/MaPle"
    
    static var friendsListIndex = Dictionary<String,String>()
    
    let USERPROFILE_URL = BASEURL + "/User_profileServlet"
    let CPOST_URL = BASEURL + "/CpostServlet"
    let PICTURE_URL = BASEURL + "/PictureServlet"
    let CHART_URL = BASEURL + "/ChartServlet"
    static let shared = Communicator()
    
    private init(){}
    //getMemberIdByPostId
    let MEMBERID_KEY = "memberId"
    let RESULT_KEY = "result"
    let USERPROFILE_KEY = "userprofile"
    let DATA_KEY = "data"
    let ACTION_KEY = "action"
    let FINDBYID_KEY = "findById"
    let UPDATE_KEY = "update"
    let GETPOST_KEY = "getPost"
    let DELETEPOST_KEY = "deletePost"
    let UPDATEPOST_KEY = "updatePost"
    let INSERTPOST_KEY = "insert"
    let IMAGEBASE64_KEY = "imageBase64"
    let LOCATION_KEY = "locationTable"
    let FINDOTHERBYID = "findotherById"
    let GETBYMEMBERID_KEY = "getBymemberId"
    let POSTID_KEY = "postId"
    
    typealias DoneHandler = (_ result: Any? , _ error: Error?) -> Void
    typealias DownloadDoneHandler = (_ result: Data?, _ error: Error?) -> Void
    
    func getPost(postId:Int, completion:@escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY:GETPOST_KEY, POSTID_KEY: postId]
        doPost(urlString: CPOST_URL, parameters: parameters, completion: completion)
        printHelper.println(tag: "Communicator", line: #line, #function)
        print("getPost parameters:\(parameters)")
        
    }
    
    func getMemberIdByPostId(postId:Int, completion:@escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY:"getMemberIdByPostId", POSTID_KEY: postId]
        doPost(urlString: CPOST_URL, parameters: parameters, completion: completion)
        printHelper.println(tag: "Communicator", line: #line, #function)
        print("getMemberIdByPostId parameters:\(parameters)")
        
    }
    
    func getAllPostsByMemberId(memberId: Int,completion:@escaping DoneHandler ) {
        let parameters: [String : Any] = [ACTION_KEY:"getByMemberId", "memberid": memberId]
        doPost(urlString: PICTURE_URL, parameters: parameters, completion: completion)
        printHelper.println(tag: "Communicator", line: #line, #function)
        print("getAllPostsByMemberId parameters:\(parameters)")
    }
    
    func deletePost(postId: Int, completion:@escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY:DELETEPOST_KEY, POSTID_KEY: postId]
        doPost(urlString: CPOST_URL, parameters: parameters, completion: completion)
        printHelper.println(tag: "Communicator", line: #line, #function)
        print("parameters:\(parameters)")
    }
    
    func updatePost(postId: Int, imageBase64: String, post: UpdatePost, completion:@escaping DoneHandler){
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(post)
        let json = String(data: jsonData, encoding: .utf8)!
        let parameters: [String : Any] = [ACTION_KEY: "update", POSTID_KEY: postId,IMAGEBASE64_KEY:imageBase64, "updatePost": json]
        doPost(urlString: CPOST_URL, parameters: parameters, completion: completion)
        printHelper.println(tag: "Communicator:", line: #line,#function)
        
    }
    
    
    func updateUserprofile(userProfile: Userprofile, imageBase64: String, completion:@escaping DoneHandler){
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(userProfile)
        let json = String(data: jsonData, encoding: .utf8)!
        let parameters: [String : Any] = [ACTION_KEY:"update", "userprofile": json, IMAGEBASE64_KEY: imageBase64]
        doPost(urlString: USERPROFILE_URL, parameters: parameters, completion: completion)
        printHelper.println(tag: "Communicator:", line: #line,#function)
        //        print("updateUserprofile parameters:\(parameters)")
        
    }
    
    func insertNewPost(memberId: Int, imageBase64: String, comment: String, locationTable: Location, completion: @escaping DoneHandler){
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(locationTable)
        let json = String(data: jsonData, encoding: .utf8)!
        let parameters: [String : Any] = [ACTION_KEY:INSERTPOST_KEY, MEMBERID_KEY: memberId, IMAGEBASE64_KEY:imageBase64, LOCATION_KEY: json, "comment": comment]
        
        doPost(urlString: CPOST_URL, parameters: parameters, completion: completion)
       
        printHelper.println(tag: "Communicator:", line: #line,#function)
        
    }
    
    func getCountryCode(memberId: Int, completion:@escaping DoneHandler ) {
        let parameters: [String : Any] = [ACTION_KEY:"getCountryCode", MEMBERID_KEY: memberId]
        doPost(urlString: CHART_URL, parameters: parameters, completion: completion)
        printHelper.println(tag: "Communicator", line: #line, #function)
        print("parameters:\(parameters)")
    }
    
    func getVisitedStatic(memberId: Int, completion:@escaping DoneHandler ) {
        let parameters: [String : Any] = [ACTION_KEY:"getVisitedStatic", MEMBERID_KEY: memberId]
        doPost(urlString: CHART_URL, parameters: parameters, completion: completion)
        printHelper.println(tag: "Communicator", line: #line, #function)
        print("parameters:\(parameters)")
    }
    
    
    func downloadPhoto(url:String, completion: @escaping DownloadDoneHandler) {
        //        let finalURLString = PHOTO_BASE_URL + filename
        Alamofire.request(url).responseData { (response) in
            switch response.result {
            case .success(let data) :
                print("Photo Download OK: \(data.count) bytes")
                completion(data, nil)
            case .failure(let error) :
                print("Photo Download Fail: \(error)")
                completion(nil, error)
            }
        }
    }
    
    
    func doPost(urlString: String, parameters:[String : Any]?, completion: @escaping DoneHandler ){
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
            self.handleJson(response: response, completion: completion)
        })
        
    }
    func doPostData(urlString: String, parameters:[String : Any]?, completion: @escaping DownloadDoneHandler ){
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { (response) in
            switch response.result {
            case .success(let data):
                print("data:\(data)")
                completion(data,nil)
            case .failure(let error):
                print("error:\(error)")
                completion(nil,error)
                
            }
        }
        
    }
    
    
    
    
    
    
    func handleJson(response: DataResponse<Any>, completion: DoneHandler) {
        
        print("response:\(response)")
        switch response.result {
            
        case .success(let json):
            print("Get success response:\(json)")
            completion(json, nil)
            
        case .failure( let error):
            print("Server respond error:\(error)")
            completion(nil, error)
        }
    }
}







