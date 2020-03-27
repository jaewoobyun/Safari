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
		
		initSetting()
	}
	
	
	
//	@IBInspectable var accEnabled: Bool {
//		get {
//			return isAccessibilityElement
//		}
//		set {
//			isAccessibilityElement = newValue
//		}
//	}
	
//	override init() {
//		super.init()
//	}
	
	func initSetting() {
		
		self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray], for: UIControl.State.disabled)
		self.isEnabled = false
		
		if let customView = self.customView {
			print("customView!")
//			self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.systemBlue], for: UIControl.State.normal)
//			self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray], for: UIControl.State.disabled)
			
		} else {
			print("customView is nil?")
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

//class CustomBarButtonItem: UIBarButtonItem {
//	private (set) var button: UIButton!
//
//	override var tintColor: UIColor? {
//		get { return button.tintColor }
//		set { button.tintColor = newValue }
//	}
//
//	convenience init(button: UIButton) {
//		self.init(customView: button)
//		self.button = button
//		button.imageView?.contentMode = .scaleAspectFit
//		button.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
//	}
//}
