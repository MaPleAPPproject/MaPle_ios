//
//  FriendlistTableViewCell.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/11/28.
//

import UIKit

class FriendlistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var introLB: UILabel!
    @IBOutlet weak var chatBt: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        } else {
            backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    
    

}
