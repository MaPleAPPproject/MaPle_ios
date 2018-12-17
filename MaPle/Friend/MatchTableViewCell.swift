//
//  MatchTableViewCell.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/12/5.
//

import UIKit

class MatchTableViewCell: UITableViewCell {

    @IBOutlet weak var photoIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var introLB: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cardbackgroundView: CardView!
    @IBOutlet weak var photobackgroundView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }else {
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        } else {
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }

    @IBAction func dislikeBtPress(_ sender: UIButton) {
        self.likeButton.isHidden = true
        sender.isHidden = true
        statusLabel.text = "❌\t已拒絕配對 "
        statusLabel.isHidden = false
    }
    
    @IBAction func likeBtPress(_ sender: UIButton) {
        self.dislikeButton.isHidden = true
        sender.isHidden = true
        statusLabel.text = "⭕️\t已接受配對 \n 發送交友邀請囉"
        statusLabel.isHidden = false
    }
    
    
    
}
