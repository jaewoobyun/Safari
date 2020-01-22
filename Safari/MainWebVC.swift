//
//  MainWebVC.swift
//  Safari
//
//  Created by 변재우 on 20200121//.
//  Copyright © 2020 변재우. All rights reserved.
//

import UIKit
import WebKit

@objc protocol ViewControllerDelegate {
	@objc optional func viewControllerDidReceiveTap(_ viewController: MainWebVC)
	@objc optional func viewControllerDidRequestDelete(_ viewController: MainWebVC)
}

class MainWebVC: UIViewController{
	
	var delegate: ViewControllerDelegate?
	
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet weak var addresslb: UILabel!
	@IBOutlet weak var webView: WKWebView!
	
	var headerVisible:Bool = false
	

	
//	var visitedWebSiteHistoryRecords: [] = [] //FIXME: HistoryData
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//-------------------
		let urlString = "https://www.google.com"
		let url = URL(string: urlString)
		let urlRequest = URLRequest(url: url!)
		webView.load(urlRequest)
		//---------------------
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MainWebVC.onBackgroundTap(_:)))
		self.view.addGestureRecognizer(tapGesture)
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	// MARK: - UI Related methods
	func setHeaderVisible(_ visible:Bool, animated:Bool) {
		self.headerVisible = visible
		if self.isViewLoaded == false {
			return
		}
		UIView.animate(withDuration: (animated ? 0.25 : 0.0)) {
			self.deleteButton?.alpha = (visible ? 1.0 : 0.0)
			self.addresslb?.alpha = (visible ? 1.0 : 0.0)
//			self.searchBar.alpha = (visible ? 0.0 : 1.0)
		}
	}
	
	func blockUserInteractionWhenOpeningTab(_ visible:Bool) {
		guard let webView = self.webView else { return }
		webView.isUserInteractionEnabled = (visible ? false : true)
	}
	
	@IBAction fileprivate func onDeleteButtonTap(_ sender: UIButton) {
		self.delegate?.viewControllerDidRequestDelete?(self)
	}
	
	@objc func onBackgroundTap(_ tapGesture:UITapGestureRecognizer) {
		self.delegate?.viewControllerDidReceiveTap?(self)
	}
	
}



class MainWebView: UIView {
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, with: event)
		
		if hitView == self {
			return nil
		}
		
		return hitView
	}
}
