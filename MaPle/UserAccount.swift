//
//  UserAccount.swift
//  MaPle
//
//  Created by Bron on 2018/11/21.
//

import Foundation

struct UserAccount: Codable {
//    var MemberId:String
    var Email:String
    var PassWord:String
//    var UserName:String
//    var ProfileIcon:String
//    var SelfIntroduction:String
//    var VipStatus:String
    enum CodingKeys:String ,CodingKey{
//        case MemberId = "MemberId"
        case Email = "Email"
        case PassWord = "PassWord"
//        case UserName = "UserName"
//        case ProfileIcon = "ProfileIcon"
//        case SelfIntroduction = "SelfIntroduction"
//        case VipStatus = "VipStatus"
    }
}
