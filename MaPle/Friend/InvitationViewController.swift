//
//  InvitationViewController.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/11/29.
//

import UIKit

let  MAX_BUFFER_SIZE = 3;
let  SEPERATOR_DISTANCE = 8;
let  TOPYAXIS = 75;

class InvitationViewController: UIViewController {

    @IBOutlet var containerView: GradientView!
    @IBOutlet weak var emojiView: EmojiRateView!
    @IBOutlet weak var viewTinderBackGround: UIView!
    @IBOutlet weak var viewActions: UIView!
    var selectedViewController: UIViewController!

    
    var currentIndex = 0
    var currentLoadedCardsArray = [TinderCard]()
    var allCardsArray = [TinderCard]()
    var valueArray = ["1"]
    let communicator = FriendCommunicator.shared
    let explorecommunicator = ExploreCommunicator.shared
    var friends = [Friend_profile]()
    var friendsNames = [String]()
    var iconData: Data?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActions.alpha = 0
        getallInvitation()
        selectedViewController = self.parent
        let notificationName = Notification.Name("GetMemberIDtoButton")
        NotificationCenter.default.addObserver(self, selector: #selector(self.clickProfileButton(noti:)), name: notificationName, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.layoutIfNeeded()
    }
    
    @objc func animateEmojiView(timer : Timer){
        let sender = timer.userInfo as! EmojiRateView
        emojiView.rateValue =  emojiView.rateValue + 0.2
        if sender.rateValue >= 5 {
            timer.invalidate()
            emojiView.rateValue = 2.5
        }
    }
    
    @objc
    func clickProfileButton(noti: Notification?) {
        //object from TinderCard method(clickProfileButton), object= [Any] = userid, username
        guard let object = noti?.object as? [Any] else {
            assertionFailure("userid is nil")
            return
        }
        if let controller = storyboard?.instantiateViewController(withIdentifier: "othersPage") as? OthersPage2CollectionViewController {

            controller.memberid = object[0] as! Int
            controller.userName = object[1] as! String
            controller.iconData = iconData
            controller.navigationItem.leftItemsSupplementBackButton = true
            self.parent?.view.addSubview(controller.view)
            self.view.addSubview(controller.view)
            show(controller, sender: self)
        }
    }
    
    func getallInvitation() {
        let memberid = 1
        communicator.getAllInvitation(memberid: memberid) { (result,error) in
            if let error = error {
                print("getallInvitation error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            guard let jsonObject = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                else {
                    print("Fail to generate jsonData")
                    return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([Friend_profile].self, from: jsonObject) else {
                print("Fail to decode jsonData.")
                return
            }
            print("\(resultObject)")
            for friend in resultObject {
                self.friends.append(friend)
            }
            print(self.friends.description)
            self.loadCardValues(friends: self.friends)

        }
    }
    
    func loadCardValues(friends: [Friend_profile]) {
        
        if friends.count > 0 {

            let capCount = (friends.count > MAX_BUFFER_SIZE) ? MAX_BUFFER_SIZE : valueArray.count

            for (i,value) in friends.enumerated() {
                let newCard = createTinderCard(at: i,selfintro: friends[i].selfIntroduction,names:friends[i].Username,friend: value)
                allCardsArray.append(newCard)
                if i < capCount {
                    currentLoadedCardsArray.append(newCard)
                }
            }
            
            for (i,_) in currentLoadedCardsArray.enumerated() {
                if i > 0 {
                    viewTinderBackGround.insertSubview(currentLoadedCardsArray[i], belowSubview: currentLoadedCardsArray[i - 1])
                }else {
                    viewTinderBackGround.addSubview(currentLoadedCardsArray[i])
                }
            }
            animateCardAfterSwiping()
            perform(#selector(loadInitialDummyAnimation), with: nil, afterDelay: 1.0)
        }
    }
    
    @objc func loadInitialDummyAnimation() {
        
        let dummyCard = currentLoadedCardsArray.first;
        dummyCard?.shakeAnimationCard()
        UIView.animate(withDuration: 1.0, delay: 2.0, options: .curveLinear, animations: {
            self.viewActions.alpha = 1.0
        }, completion: nil)
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.animateEmojiView), userInfo: emojiView, repeats: true)
    }
    
    func createTinderCard(at index: Int , selfintro :String, names:String,friend: Friend_profile ) -> TinderCard {
        
        let card = TinderCard(frame: CGRect(x: 0, y: 0, width: self.viewTinderBackGround.frame.size.width , height: viewTinderBackGround.frame.size.height - 50) ,value : selfintro, names: names,friend: friend )
        card.delegate = self
        return card
    }
    
    func removeObjectAndAddNewValues() {
        
        emojiView.rateValue =  2.5
        UIView.animate(withDuration: 0.5) {
        //button undo
        }
        currentLoadedCardsArray.remove(at: 0)
        currentIndex = currentIndex + 1
//        Timer.scheduledTimer(timeInterval: 1.01, target: self, selector: #selector(enableUndoButton), userInfo: currentIndex, repeats: false)
        
        if (currentIndex + currentLoadedCardsArray.count) < allCardsArray.count {
            let card = allCardsArray[currentIndex + currentLoadedCardsArray.count]
            var frame = card.frame
            frame.origin.y = CGFloat(MAX_BUFFER_SIZE * SEPERATOR_DISTANCE)
            card.frame = frame
            currentLoadedCardsArray.append(card)
            viewTinderBackGround.insertSubview(currentLoadedCardsArray[MAX_BUFFER_SIZE - 1], belowSubview: currentLoadedCardsArray[MAX_BUFFER_SIZE - 2])
        }
        print(currentIndex)
        animateCardAfterSwiping()
    }
    
    func animateCardAfterSwiping() {
        
        for (i,card) in currentLoadedCardsArray.enumerated() {
            UIView.animate(withDuration: 0.5, animations: {
                if i == 0 {
                    card.isUserInteractionEnabled = true
                }
                var frame = card.frame
                frame.origin.y = CGFloat(i * SEPERATOR_DISTANCE)
                card.frame = frame
            })
        }
    }
    
    @IBAction func disLikeButton(_ sender: Any) {
        let card = currentLoadedCardsArray.first
        card?.leftClickAction()
    }
    
    @IBAction func likeButton(_ sender: Any) {
        let card = currentLoadedCardsArray.first
        card?.rightClickAction()
    }
}


extension InvitationViewController : TinderCardDelegate{
    
    // action called when the card goes to the left.
    func cardGoesLeft(card: TinderCard) {
        removeObjectAndAddNewValues()
    }
    // action called when the card goes to the right.
    func cardGoesRight(card: TinderCard) {
        removeObjectAndAddNewValues()
    }
    func currentCardStatus(card: TinderCard, distance: CGFloat) {
        
        if distance == 0 {
            emojiView.rateValue =  2.5
        }else{
            let value = Float(min(abs(distance/100), 1.0) * 5)
            let sorted = distance > 0  ? 2.5 + (value * 5) / 10  : 2.5 - (value * 5) / 10
            emojiView.rateValue =  sorted
        }
    }
    
    

}
