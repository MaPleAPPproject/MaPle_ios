//
//  RetriveFriend.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/11/23.
//

import Foundation

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

struct ChatMessage : Codable {
    var type: String
    var sender: String
    var senderName: String
    var receiver: String
    var content: String
    var messageType: String
    
    init(type: String, sender: String, senderName: String, receiver: String, content: String, messageType: String) {
        self.type = type
        self.sender = sender
        self.senderName = senderName
        self.receiver = receiver
        self.content = content
        self.messageType = messageType
    }
    
}

struct StateMessage: Codable {
    var type: String
    var user: String
    var users: Set<String>
    var userName: String
    
    init(type: String, user: String, users: Set<String>, userName: String) {
        self.type = type
        self.user = user
        self.users = users
        self.userName = userName
    }
}


