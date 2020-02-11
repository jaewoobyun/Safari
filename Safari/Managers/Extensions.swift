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
