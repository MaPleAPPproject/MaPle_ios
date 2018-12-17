//
//  ImageManager.swift
//  MaPle
//
//  Created by juiying chiu on 2018/11/28.
//

import Foundation
import UIKit

class ImageManager {
    
    static let shared = ImageManager()
    private init(){}
    
    
     func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    //
    // Convert a base64 representation to a UIImage
    //
     func convertBase64ToImage(imageString: String) -> UIImage {
        let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData)!
    }
    
//    func showAlert(){
//        let alert = UIAlertController(title: "更換照片", message: "請選擇照片選取來源", preferredStyle: .actionSheet)
//        let act
//    }
    
    

}

