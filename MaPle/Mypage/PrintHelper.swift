//
//  PrintHelper.swift
//  MaPle
//
//  Created by juiying chiu on 2018/11/19.
//

import Foundation

// 範例
// printHelper.println(tag: "ProductPageViewController", line: #line, "MAG")

// 輸出結果
// 在 ProductPageViewController 的 50 行,
// 訊息：MAG

import Foundation

final class printHelper {
    static func println(tag: String, line: Int, _ msg: String) {
        print("在 \(tag) 的 \(line) 行,\n訊息：\(msg) ")
    }
    
    static func printLog(item msg: Any) {
        
        print("msg:",msg)
    }
   
}
