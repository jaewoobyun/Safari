//
//  Extensions.swift
//  Safari
//
//  Created by 변재우 on 20200204//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit


/// To hide the keyboard when clicking around??
extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard(_:)))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
		view.endEditing(true)
		
		if let nav = self.navigationController {
			nav.view.endEditing(true)
		}
	}
}

//extension UIBarButtonItem {
//	var view: UIView? {
//		return value(forKey: "view") as? UIView
//	}
//	func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
//		view?.addGestureRecognizer(gestureRecognizer)
//	}
//}

// MARK: - UIColor Extension (for icon)
extension UIColor {
	public static var random: UIColor {
		let max = CGFloat(UInt32.max)
		let red = CGFloat(arc4random()) / max
		let green = CGFloat(arc4random()) / max
		let blue = CGFloat(arc4random()) / max
		
		return UIColor(red: red, green: green, blue: blue, alpha: 0.7)
	}
	
	/// rgb 만 들어와야함. 0x FF FF FF
	convenience init(rgb: UInt) {
		 self.init(
			  red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
			  green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
			  blue: CGFloat(rgb & 0x0000FF) / 255.0,
			  alpha: CGFloat(1.0)
		 )
	}
}


