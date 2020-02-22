//
//  CustomBarButton.swift
//  Safari
//
//  Created by 변재우 on 20200207//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit

class CustomBarButton: UIBarButtonItem {
	let touchView: UIView = UIView()
	let imageView: UIImageView = UIImageView()
	
	var tapEvent: (()->())?
	var longEvent: (()->())?
	
	override class func awakeFromNib() {
		super.awakeFromNib()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
//		self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.lightGray], for: UIControl.State.disabled)
		
		initSetting()
	}
	
	func initSetting() {
		if let customView = self.customView {
			print("customView!");
			
		} else {
			print("customview is nil")
			
			touchView.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
			self.customView = touchView
			
			imageView.frame = touchView.frame
			imageView.image = self.image
			touchView.addSubview(imageView)
			imageView.contentMode = .scaleAspectFit
			
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
			
			let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(long))
			
			tapGesture.numberOfTouchesRequired = 1
			longGesture.minimumPressDuration = 0.5
			longGesture.numberOfTouchesRequired = 1
			touchView.addGestureRecognizer(tapGesture)
			touchView.addGestureRecognizer(longGesture)
			
			touchView.isUserInteractionEnabled = true
			
		}
	}
	
	@objc func tap() {
		if let tapEvent = self.tapEvent {
			tapEvent()
		}
	}
	
	@objc func long() {
		if let longEvent = self.longEvent {
			longEvent()
		}
	}
	
}
