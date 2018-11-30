//
//  RetriveFriend.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/11/23.
//

import Foundation

struct UserProfile : Codable {
    var memberId: Int
    var email: String
    var password: String
    var userName: String
    var selfIntroduction: String
    var vipStatus: Int
    var postCount: Int
    var collectionCount: Int
    
    enum CodingKeys: String, CodingKey {
        case memberId = "memberId"
        case email = "email"
        case password = "password"
        case userName = "userName"
        case selfIntroduction = "selfIntroduction"
        case vipStatus = "vipStatus"
        case postCount = "postcount"
        case collectionCount = "collectcount"
    }
    
    init(memberId:Int,email: String, password: String, userName: String, selfIntroduction: String, vipStatus: Int, postCount:Int, collectionCount: Int) {
        self.memberId = memberId
        self.email = email
        self.password = password
        self.userName = userName
        self.selfIntroduction = selfIntroduction
        self.vipStatus = vipStatus
        self.postCount = postCount
        self.collectionCount = collectionCount
    }
   
}

struct Friendlist : Codable {
    var MatchID: Int
    var RelationshipStatus: Int
    var MemberID: Int
    var FriendID: Int
    var MessageRoom: Int
    
    init(MatchID:Int, RelationshipStatus:Int, MemberID:Int, FriendID:Int, MessageRoom: Int) {
        self.MatchID = MatchID
        self.RelationshipStatus = RelationshipStatus
        self.MemberID = MemberID
        self.FriendID = FriendID
        self.MessageRoom = MessageRoom
    }
}


struct Friend_profile : Codable {
    var FriendID : Int
    var Username: String
    var selfIntroduction: String
    var vipStatus : Int
    var postcount : Int
    var collectcount : Int
    
    enum CodingKeys: String, CodingKey {
        case FriendID = "memberId"
        case Username = "userName"
        case selfIntroduction = "selfIntroduction"
        case vipStatus = "vipStatus"
        case postcount = "postcount"
        case collectcount = "collectcount"
    }
    init(collectcount: Int, FriendID:Int, postcount: Int, selfIntroduction: String, Username: String, vipStatus:Int) {
        self.FriendID = FriendID
        self.Username = Username
        self.selfIntroduction = selfIntroduction
        self.vipStatus = vipStatus
        self.postcount = postcount
        self.collectcount = collectcount
    }
    
}
