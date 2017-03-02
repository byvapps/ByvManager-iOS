//
//  ByvPaginatedLoadingCell.swift
//  camionapp
//
//  Created by Adrian Apodaca on 27/2/17.
//  Copyright © 2017 CamionApp. All rights reserved.
//

import UIKit
import ByvUtils

class ByvPaginatedLoadingCell: UITableViewCell {
    
    let aiv = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func didMoveToSuperview() {
        aiv.tintColor = UIColor.gray
        aiv.startAnimating()
        aiv.tag = 310584
        aiv.addTo(self.contentView, position: .all, centered: true, width: aiv.bounds.size.width, height: aiv.bounds.size.height)
        self.selectionStyle = .none
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
