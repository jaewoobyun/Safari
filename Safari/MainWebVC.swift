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
	@objc optional func requestLoad(_ viewController: MainWebVC)
	
//	@objc optional func canGoBack()s
}

class MainWebVC: UIViewController{
	
	var delegate: ViewControllerDelegate?
	
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet weak var addresslb: UILabel!
	@IBOutlet weak var webView: WKWebView!
	@IBOutlet weak var progressView: UIProgressView!
	
	var headerVisible:Bool = false
	
	var urlString: String = "https://www.google.com"
	
//	var currentContentMode: WKWebpagePreferences.ContentMode?
//	var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
//	var estimatedProgressObservationToken: NSKeyValueObservation?
//	var canGoBackObservationToken: NSKeyValueObservation?
//	var canGoForwardObservationToken: NSKeyValueObservation?
	
	
//	var visitedWebSiteHistoryRecords: [] = [] //FIXME: HistoryData
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//-------------------
//		let urlString = "https://www.google.com"
		let url = URL(string: urlString)
		let urlRequest = URLRequest(url: url!)
		webView.load(urlRequest)
		
		self.addresslb.text = urlString
		//---------------------r
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MainWebVC.onBackgroundTap(_:)))
		self.view.addGestureRecognizer(tapGesture)
		
		setUpProgressObservation()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.delegate?.requestLoad?(self)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.delegate?.requestLoad?(self)
		
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
		}
	}
	
	func blockUserInteractionWhenOpeningTab(_ visible:Bool) {
		if self.isViewLoaded == false {
			return
		}
		webView.isUserInteractionEnabled = (visible ? false : true)
	}
	
	
	@IBAction fileprivate func onDeleteButtonTap(_ sender: UIButton) {
		self.delegate?.viewControllerDidRequestDelete?(self)
	}
	
	@objc func onBackgroundTap(_ tapGesture:UITapGestureRecognizer) {
		self.delegate?.viewControllerDidReceiveTap?(self)
		
	}
	
	func setUpProgressObservation() {
		Observables.shared.estimatedProgressObservationToken = webView.observe(\.estimatedProgress) { (object, change) in
			let estimatedProgress = self.webView.estimatedProgress
			self.progressView.alpha = 1
			self.progressView.progress = Float(estimatedProgress)
			if estimatedProgress >= 1 { //로딩이 끝나면 progressview 를 안 보이게 해준다.
				self.progressView.alpha = 0
			}
		}
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
