//
//  ReadingListCell.swift
//  Safari
//
//  Created by 변재우 on 20200212//.
//  Copyright © 2020 변재우. All rights reserved.
//

import UIKit
import FavIcon

class ReadingListCell: UITableViewCell {
	
	@IBOutlet weak var iconImage: UIImageView!
	@IBOutlet weak var iconInitialLetter: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		iconImage.layer.cornerRadius = 5
		iconImage.clipsToBounds = true
	}
	
	func setCellData(_ data: ReadingListData? = nil) {
		if let data = data {
			titleLabel.text = data.title
			detailLabel.text = data.urlString
			//			iconInitialLetter.text = data.getFirstIconLetter()
			//			iconImage.backgroundColor = data.getIconLetterColor()
			if data.urlString != nil {
				do {
					try FavIcon.downloadPreferred(data.urlString!, completion: { (result) in
						if case let .success(image) = result {
							self.iconImage.image = image
						}
						else if case let .failure(error) = result {
							print("failed to download preferred favicon for \(String(describing: data.urlString)): \(error)")
							//?
							self.iconInitialLetter.text = data.getFirstIconLetter()
							self.iconImage.backgroundColor = data.getIconLetterColor()
						}
					})
				}
				catch let error {
					print("failed to download preferred favicon for \(String(describing: data.urlString)): \(error)")
					//?
					self.iconInitialLetter.text = data.getFirstIconLetter()
					self.iconImage.backgroundColor = data.getIconLetterColor()
				}
			}
			
		} else {
			titleLabel.text = ""
			detailLabel.text = ""
			iconInitialLetter.text = ""
		}
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}
