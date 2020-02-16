//
//  FolderCell.swift
//  SafariSample
//
//  Created by Nomad on 2019/11/29.
//  Copyright © 2019 Nomad. All rights reserved.
//

import UIKit

class FolderCell: UITableViewCell {
	
	@IBOutlet weak var icon: UIImageView!
	@IBOutlet weak var folderName: UILabel!
	@IBOutlet weak var leadingConstraint: NSLayoutConstraint!
	
	let leadingValueForChildrenCell: CGFloat = 30

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	///Determine if cell should be a folder or a bookmark
	func setupIconFolderOrBook(_ data: BookmarkData? = nil) {
		if let data = data {
			if data.isFolder {
				self.icon.image = UIImage(systemName: "folder")
			}
			else {
				self.icon.image = UIImage(systemName: "book")
			}
		}
	}
	
	func setupCell(level: Int) {
		self.leadingConstraint.constant = leadingValueForChildrenCell * CGFloat(level + 1)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		accessoryType = selected ? .checkmark : .none
		self.icon.tintColor = selected ? UIColor.systemBlue : UIColor.systemGray
    }
    
}
