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
	
	var urlString: String?
	
//	init(urlString: String?) {
//		super.init()
//		self.urlString = urlString
//	}
//
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
	
//	var currentContentMode: WKWebpagePreferences.ContentMode?
//	var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
//	var estimatedProgressObservationToken: NSKeyValueObservation?
//	var canGoBackObservationToken: NSKeyValueObservation?
//	var canGoForwardObservationToken: NSKeyValueObservation?
	
	
//	var visitedWebSiteHistoryRecords: [] = [] //FIXME: HistoryData
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var loadedExistingURL = false
		if let lastCommittedURLStringString = UserDefaults.standard.object(forKey: "LastCommittedURLString") as? String {
			self.urlString = lastCommittedURLStringString
			if let url = URL(string: lastCommittedURLStringString) {
				//searchBar.text = lastCommittedURLStringString
				webView.load(URLRequest(url: url))
				loadedExistingURL = true
			}
		}
		
		if !loadedExistingURL {
			loadStartPage()
		}
		
		self.addresslb.text = urlString
		//---------------------r
		
		self.webView.navigationDelegate = self
		self.webView.allowsBackForwardNavigationGestures = true
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MainWebVC.onBackgroundTap(_:)))
		self.view.addGestureRecognizer(tapGesture)
		
		setUpProgressObservation()
		registerObserverToNotifiationGroup()
		
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
		NotificationGroup.shared.removeAllObserver(vc: self)
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
	
	func registerObserverToNotifiationGroup() {
		UserDefaultsManager.shared.initDatas()
		///Registering bookmark observer
		NotificationGroup.shared.registerObserver(type: .bookmarkURLName, vc: self, selector: #selector(onBookmarkNotification(notification:)))
		
		///Registering history observer
		NotificationGroup.shared.registerObserver(type: .historyURLName, vc: self, selector: #selector(onHistoryNotification(notification:)))
		
		///Registering ReadingList Observer
		NotificationGroup.shared.registerObserver(type: .readinglistURLName, vc: self, selector: #selector(onReadingListNotification(notification:)))
		
	}
	
	@objc func onBookmarkNotification(notification: Notification) {
		if let url = notification.userInfo?["selectedBookmarkURL"] as? String {
			loadWebViewFromURL(urlString: url)
		}
	}
	
	@objc func onHistoryNotification(notification: Notification) {
		if let url = notification.userInfo?["selectedHistoryURL"] as? String {
			loadWebViewFromURL(urlString: url)
		}
	}
	
	@objc func onReadingListNotification(notification: Notification) {
		if let url = notification.userInfo?["selectedReadingListURL"] as? String {
			loadWebViewFromURL(urlString: url)
		}
	}
	
	func loadStartPage() {
		if let bookmarksURL = Bundle.main.url(forResource: "bookmarks_11_19_19", withExtension: "html") {
			//searchBar.text = "bookmarks_11_19_19.html"
			webView.loadFileURL(bookmarksURL, allowingReadAccessTo: Bundle.main.bundleURL)
		}
	}
	
	func loadWebViewFromURL(urlString: String?) {
		///http://AAA.com
		guard var urlString = urlString?.lowercased() else { return }
		guard let url: URL = URL.init(string: urlString) else {
			return
		}
		if UIApplication.shared.canOpenURL(url) {
			//TODO: - Not sure
			self.webView.load(URLRequest(url: url))
		}
		
		if !urlString.contains("://") {
			if urlString.contains("localhost") || urlString.contains("127.0.0.1") {
				urlString = "http://" + urlString
			} else {
				urlString = "https://" + urlString
			}
		}
		if webView.url?.absoluteString == urlString {
			return
		}
		if let targetURL = URL(string: urlString) {
			webView.load(URLRequest(url: targetURL))
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


extension MainWebVC: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		print("didStartProvisionalNavigation")
	}
	
	func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
		print("WebView didCommit")
//		if let url = webView.url {
//			if url.scheme != "file" {
//				if let urlString = webView.url?.absoluteString {
//					UserDefaults.standard.set(urlString, forKey: "LastCommittedURLString")
//					//searchBar.text = urlString
//				}
//			}
//			else {
//				UserDefaults.standard.removeObject(forKey: "LastCommittedURLString")
//				//searchBar.text = url.lastPathComponent
//			}
//		}
		
		if webView.url?.scheme == "file" {
			print("webView did commit file Scheme")
		}
		if webView.url?.scheme == "https" {
			print("webView did commit https Scheme")
			if let urlString = webView.url?.absoluteString {
				UserDefaults.standard.set(urlString, forKey: "LastCommittedURLString")
				self.addresslb.text = urlString
				NotificationGroup.shared.post(type: NotificationGroup.NotiType.urlUpdate, userInfo: ["urlString": urlString])
			}
//			Observables.shared.urlsObservationToken = webView.url
		}
		if webView.url?.scheme == "http" {
			print("webView did commit http Scheme")
		}
		Observables.shared.currentContentMode = navigation.effectiveContentMode
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		print("didFinish")
		
		let backForwardList = self.webView.backForwardList.self
		guard let currentItemUrl = backForwardList.currentItem?.url else { return }
		guard let currentItemInitialUrl = backForwardList.currentItem?.initialURL else { return }
		guard let currentItemTitle = backForwardList.currentItem?.title else { return }
		guard let currentItemUrlString = backForwardList.currentItem?.url.absoluteString else { return }
		let now = Date()
		
		let historyDataInstance = HistoryData(url: currentItemUrl, initialUrl: currentItemInitialUrl, title: currentItemTitle, urlString: currentItemUrlString, date: now)
		
		UserDefaultsManager.shared.insertCurrentPage(historyData: historyDataInstance)
		print("backList")
		print(self.webView.backForwardList.backList.description)
		
		var backList = self.webView.backForwardList.backList
		var forwardList = self.webView.backForwardList.forwardList
		
		UserDefaultsManager.shared.insertBackListItem(currentWebView: currentItemTitle, backList: backList)
		UserDefaultsManager.shared.insertForwardListItem(currentWebView: currentItemTitle, forwardList: forwardList)
//		UserDefaults.standard.removeObject(forKey: "LastCommittedURLString") // ?????????????????
		
//		NotificationGroup.shared.post(type: NotificationGroup.NotiType.backListData, userInfo: ["backListStack": backList])
//		NotificationGroup.shared.post(type: NotificationGroup.NotiType.forwardListData, userInfo: ["forwardListStack": forwardList])
		
		
	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
		if let hostName = navigationAction.request.url?.host {
			if let preferredContentMode = Observables.shared.contentModeToRequestForHost[hostName] {
				preferences.preferredContentMode = preferredContentMode
			}
		} else if navigationAction.request.url?.scheme == "file" {
			if let preferredContentMode = Observables.shared.contentModeToRequestForHost[hostNameForLocalFile] {
				preferences.preferredContentMode = preferredContentMode
			}
		}
		decisionHandler(.allow, preferences)
	}
	
	
	
}
