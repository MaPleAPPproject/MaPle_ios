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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func dislikeBtPress(_ sender: UIButton) {
        self.likeButton.isHidden = true
        sender.isHidden = true
        statusLabel.text = "已拒絕配對"
        statusLabel.isHidden = false
    }
    
    @IBAction func likeBtPress(_ sender: UIButton) {
        self.dislikeButton.isHidden = true
        sender.isHidden = true
        statusLabel.text = "已接受配對，發送交友邀請囉"
        statusLabel.isHidden = false

    }
    
    
    
}
