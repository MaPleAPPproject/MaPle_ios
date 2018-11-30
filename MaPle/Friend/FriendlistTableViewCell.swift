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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func profilePressed(_ sender: UIButton) {
    }
    
    
    @IBAction func chatPressed(_ sender: UIButton) {
    }
    
    

}
