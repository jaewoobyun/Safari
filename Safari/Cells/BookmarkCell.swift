//
//  BookmarkCell.swift
//  Safari
//
//  Created by 변재우 on 20200416//.
//  Copyright © 2020 변재우. All rights reserved.
//

import UIKit

class BookmarkCell: UITableViewCell {

	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setCellData(_ data: BookmarkData? = nil) {
		if let data = data {
			self.textLabel?.text = data.titleString
			if data.isFolder {
				self.imageView?.image = UIImage(systemName: "folder")
			} else {
				self.imageView?.image = UIImage(systemName: "book")
			}
			
			if data.child.count == 0 {
				self.accessoryType = .none
			} else {
				self.accessoryType = .disclosureIndicator
			}
			
		}
	}
    
}
