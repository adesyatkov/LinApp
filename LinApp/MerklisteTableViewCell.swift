//
//  MerklisteTableViewCell.swift
//  LinApp
//
//  Created by Anton on 25.03.18.
//  Copyright © 2018 Anton. All rights reserved.
//

import UIKit

class MerklisteTableViewCell: UITableViewCell {

    @IBOutlet weak var WordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
