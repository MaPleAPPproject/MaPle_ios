    //
    //  File.swift
    //  MaPle
    //
    //  Created by Paul Chen on 2018/11/28.
    //
    import UIKit
    class LodingView: UIView {
        
        var indicator: UIActivityIndicatorView!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.indicator = self.getIndicatorView(frame)
            self.addSubview(self.indicator)
            self.indicator.startAnimating()
            self.backgroundColor = UIColor(white: 0.0, alpha: 0)
            self.isUserInteractionEnabled = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)!
        }
        
        func getIndicatorView(_ frame: CGRect) -> UIActivityIndicatorView{
            let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
            indicator.tintColor = UIColor.white
            indicator.alpha = 1
            indicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            indicator.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            return indicator
        }
        
        deinit {
            self.indicator.stopAnimating()
        }
        
}
