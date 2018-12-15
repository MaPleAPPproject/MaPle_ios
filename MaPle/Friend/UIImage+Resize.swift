//
//  UIImage+Resize.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/12/6.
//

import UIKit

extension UIImage {
    
    func resize(maxEdge: CGFloat) -> UIImage? {
        // Check if it is necessary to resize.
        guard size.width >= maxEdge || size.height >= maxEdge else {
            return self
        }
        
        // Decide final size.
        let finalSize: CGSize
        if size.width >= size.height {
            let ratio = size.width / maxEdge
            finalSize = CGSize(width: maxEdge, height: size.height / ratio)
        } else {  // height > width
            let ratio = size.height / maxEdge
            finalSize = CGSize(width: size.width / ratio, height: maxEdge)
        }
        
        // Generate a new image.
        UIGraphicsBeginImageContext(finalSize)
        let rect = CGRect(x: 0, y: 0, width: finalSize.width, height: finalSize.height)
        self.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
}

}
