//
//  MenuTableViewCell.swift
//  oldNYC-iOS
//
//  Created by Christina Leuci on 2/26/16.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuItemImage: UIImageView!
    @IBOutlet weak var menuItemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
