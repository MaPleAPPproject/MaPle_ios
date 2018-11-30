//
//  ExploreData.swift
//  MaPle
//
//  Created by Violet on 2018/11/9.
//

import Foundation
import Alamofire

struct Picture: Codable{
    var postid: Int
    var comment: String
    var date: Int64
    var district: String
    var lat: Float
    var lon: Float
    
    enum CodingKeys: String, CodingKey {
        
        case postid = "postid"
        case comment = "comment"
        case date = "date"
        case district = "district"
        case lat = "lat"
        case lon = "lon"
    }
    
}
struct LocationList: Codable{
    var postid: Int
    var countryCode: String
    var district: String
    var lat: Float
    var lon: Float
    var address: String
    
    enum CodingKeys: String, CodingKey {
        
        case address = "Address"
        case countryCode = "CountryCode"
        case district = "District"
        case lat = "Lat"
        case lon = "Lon"
        case postid = "PostId"
    }
    
}

struct Post: Codable {
    var memberid: Int
    var postid: Int
    var collectioncount: Int
    var clickcount: Int
    var date: Int64
    
    enum CodingKeys: String, CodingKey {
        case postid = "postid"
        case collectioncount = "collectioncount"
        case clickcount = "clickcount"
        case date = "date"
        case memberid = "memberid"
    }
}

struct UserPreference: Codable {
    var postid: Int
    var collectorid: Int
    var memberid: Int
    var collectcount: Int
    
    enum CodingKeys: String, CodingKey {
        case postid = "postid"
        case collectorid = "collectorid"
        case collectcount = "collectcount"
        case memberid = "memberid"
    }
}

struct PostDetail: Codable {
    var postid: Int
    var memberId: Int
    var district: String
    var collectcount: Int
    var clickcount: Int
    var username: String
    var lat: Float
    var lon: Float
    
    enum CodingKeys: String, CodingKey {
        case postid = "postId"
        case memberId = "memberId"
        case district = "district"
        case collectcount = "collectioncount"
        case clickcount = "clickcount"
        case username = "username"
        case lat = "lat"
        case lon = "lon"
    }
}
struct UserProfile: Codable {
    var email: String
    var vipStatus: Int
    var selfIntroduction: String
    var postcount: Int
    var collectcount: Int
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case vipStatus = "vipStatus"
        case selfIntroduction = "selfIntroduction"
        case postcount = "postcount"
        case collectcount = "collectcount"
    }
}
