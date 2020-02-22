//
//  HistoryCell.swift
//  Safari
//
//  Created by 변재우 on 20200216//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit

class HistoryCell: UITableViewCell {
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
