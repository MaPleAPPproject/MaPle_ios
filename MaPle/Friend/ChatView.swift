//
//  ChatView.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/12/6.
//

import UIKit

enum ChatSenderType {
    case fromMe
    case fromOthers
}
struct ChatItem {
    var text: String?
    var image: UIImage?
    var senderType: ChatSenderType
}

class ChatView: UIScrollView {
    private let padding: CGFloat = 20.0
    private var lastBubbleViewY:CGFloat = 0.0
    private(set) var allItems = [ChatItem]()
    
    func add(chatItem: ChatItem) {
        
        let bubbleView = ChatBubbleView(item: chatItem, maxWidth: self.frame.width, offsetY: lastBubbleViewY + padding)
        self.addSubview(bubbleView)
        
        // Adjust variables.
        lastBubbleViewY = bubbleView.frame.maxY
        contentSize = CGSize(width: self.frame.width, height: lastBubbleViewY)
        allItems.append(chatItem)
        
        // Scroll to bottom.
        let leftBottonRect = CGRect(x: 0, y: lastBubbleViewY - 1, width: 1, height: 1)
        scrollRectToVisible(leftBottonRect, animated: true)
        
    }
}



// MARK: - ChatBubbleView
fileprivate class  ChatBubbleView: UIView {
    
    // Constants
    let sidePaddingRate: CGFloat = 0.02
    let maxBubbleViewWidthRate: CGFloat = 0.6
    let contentMargin: CGFloat = 10.0
    let bubbleTailWidth: CGFloat = 10.0
    let textFontSize: CGFloat = 16.0
    
    // Constants from ChatView.
    let item: ChatItem
    let maxWidth: CGFloat
    let offsetY: CGFloat
    
    // Variables for subviews
    var imageView: UIImageView?
    var textLabel: UILabel?
    var backgroundImageView: UIImageView?
    var currentY: CGFloat = 0.0
    
    init(item: ChatItem, maxWidth: CGFloat, offsetY: CGFloat){       
        
        self.item = item
        self.maxWidth = maxWidth
        self.offsetY = offsetY
        
        super.init(frame: .zero)
        
        self.frame = caculateBasicFrame()
        
        prepareImageView()
        
        prepareTextLabel()
        
        decideFinalSize()
        
        prepareBackgroundImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func caculateBasicFrame() -> CGRect {
        let sidePadding = maxWidth * sidePaddingRate
        let maxBubbleViewWidth = maxWidth * maxBubbleViewWidthRate
        let offsetX: CGFloat
        if item.senderType == .fromMe {
            offsetX = maxWidth - maxBubbleViewWidth - sidePadding
        } else { //.fromOthers
            offsetX = sidePadding
        }
        // The result is just a assumption.
        return CGRect(x: offsetX, y: offsetY, width: maxBubbleViewWidth, height: 10.0)
    }
    
    private func prepareImageView() {
        
        // Check if there is a image in this chat item.
        guard let image = item.image else {
            return
        }
        
        // Decide x and y.
        var x = contentMargin
        let y = contentMargin
        if item.senderType == .fromOthers {
            x += bubbleTailWidth
        }
        
        // Decide width and height.
        let displayWidth = min(image.size.width, self.frame.width - 2 * contentMargin - bubbleTailWidth)
        let displayRatio = displayWidth / image.size.width
        let displayHeight = image.size.height * displayRatio
        
        // Decide final frame.
        let displayFrame = CGRect(x: x, y: y, width: displayWidth, height: displayHeight)
        
        let photoImageView = UIImageView(frame: displayFrame)
        self.imageView = photoImageView
        photoImageView.image = image
        
        //Make a rounded corner.
        photoImageView.layer.cornerRadius = 5.0
        photoImageView.layer.masksToBounds = true
        
        self.addSubview(photoImageView)
        currentY = photoImageView.frame.maxY
        
    }
    
    private func prepareTextLabel() {
        guard let text = item.text, !text.isEmpty else {
            return
        }
        
        // Decide x and y.
        var x = contentMargin
        let y = currentY + textFontSize/2
        
        if item.senderType == .fromOthers {
            x += bubbleTailWidth
        }
        
        
        let displayWidth = self.frame.width - 2 * contentMargin - bubbleTailWidth
        let displayFrame = CGRect(x: x, y: y, width: displayWidth, height: textFontSize)
        
        // Create and add to bubble view.
        let label = UILabel(frame: displayFrame)
        self.textLabel = label
        label.font = UIFont.systemFont(ofSize: textFontSize)
        label.numberOfLines = 0
        label.text = text
        label.sizeToFit()
        
        self.addSubview(label)
        currentY = label.frame.maxY
    }
    
    
    private func decideFinalSize() {
        let finalHieght: CGFloat = currentY + contentMargin
        var finalWidth: CGFloat = 0.0
        
        if let imageView = self.imageView {
            if item.senderType == .fromMe {
                finalWidth = imageView.frame.maxX + contentMargin + bubbleTailWidth
            } else {    //.fromOthers
                finalWidth = imageView.frame.maxX + contentMargin
            }
        }
        
        // Check finalWidth with textLabel.
        if let textLabel = self.textLabel {
            var textWidth: CGFloat
            if item.senderType == .fromMe {
                textWidth = textLabel.frame.maxX + contentMargin + bubbleTailWidth
            } else {
                //From Others
                textWidth = textLabel.frame.maxX + contentMargin
            }
            finalWidth = max(finalWidth, textWidth)
        }
        
        // Final adjustment.
        if item.senderType == .fromMe,
            self.frame.width > finalWidth {
            self.frame.origin.x += self.frame.width - finalWidth
        }
        self.frame.size = CGSize(width: finalWidth, height: finalHieght)
    }
    
    
    
    private func prepareBackgroundImageView(){
        let image: UIImage?
        
        if item.senderType == .fromMe {
            let insets = UIEdgeInsets(top: 14, left: 14, bottom: 17, right: 28)
            image = UIImage(named: "fromMe.png")?.resizableImage(withCapInsets: insets)
            
        } else { // .fromOthers
            let insets = UIEdgeInsets(top: 14, left: 22, bottom: 17, right: 20)
            image = UIImage(named: "fromOthers.png")?.resizableImage(withCapInsets: insets)
        }
        let frame = self.bounds
        let imageView = UIImageView(frame: frame)
        self.backgroundImageView = imageView
        imageView.image = image
        self.addSubview(imageView)
        self.sendSubviewToBack(imageView)
        
    }
    
    

    
}
