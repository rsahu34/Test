//
//  RtTblCell.swift
//  DemoFbLogin
//
//  Created by Soumen on 13/02/20.
//  Copyright © 2020 Soumen. All rights reserved.
//

import UIKit

class RtTblCell: UITableViewCell {
    @IBOutlet weak var rtBg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.rtBg.layer.borderWidth = 2.0
        self.rtBg.layer.borderColor = UIColor.red.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
