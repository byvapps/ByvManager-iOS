//
//  ByvPagintedLoadMoreCell.swift
//  camionapp
//
//  Created by Adrian Apodaca on 27/2/17.
//  Copyright © 2017 CamionApp. All rights reserved.
//

import UIKit

class ByvPagintedLoadMoreCell: UITableViewCell {
    
    var label:UILabel = UILabel()
    
    override func didMoveToSuperview() {
        label.frame = self.bounds
        label.text = "+"
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.addTo(self.contentView)
        self.selectionStyle = .default
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
