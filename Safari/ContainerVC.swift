//
//  ViewController.swift
//  Safari
//
//  Created by 변재우 on 20200121//.
//  Copyright © 2020 변재우. All rights reserved.
//

import UIKit
import WebKit
import SCSafariPageController
import Alamofire

let hostNameForLocalFile = ""

class ContainerVC: UIViewController, SCSafariPageControllerDataSource, SCSafariPageControllerDelegate, ViewControllerDelegate {
	
	let kDefaultNumberOfPages = 1
	var dataSource = Array<MainWebVC?>()
	let safariPageController: SCSafariPageController = SCSafariPageController()
	
	//	@IBOutlet weak var toolbar: UIToolbar!
	
	@IBOutlet weak var tabsBarView: UIView!
	@IBOutlet weak var doneButton: UIButton!
	@IBOutlet weak var addButton: UIButton!
	
	@IBOutlet weak var backButton: CustomBarButton!
	@IBOutlet weak var forwardButton: CustomBarButton!
	@IBOutlet weak var shareButton: UIBarButtonItem!
	@IBOutlet weak var bookmarksButton: CustomBarButton!
	@IBOutlet weak var tabsButton: CustomBarButton!
	
	/// for when search bar is clicked at first.
	let childBookmarkVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "BookmarkVC") as BookmarkVC
	
	/// Search Container ViewController
	var searchContainerViewController: UISearchContainerViewController?
	
	lazy var searchBar = UISearchBar(frame: CGRect.zero)
	//	let searchController = UISearchController(searchResultsController: nil)
	
	/// Search Controller to help use with filtering items in the table view.
	var searchController: UISearchController!
	
	/// Search Results table view.
	private var resultsController: SearchResultsController!
	
	/// Restoration state for UISearchController
	var restoredState = SearchControllerRestorableState()
	
	
	var urlToRequest: URL?
	var selectedPageIndex: Array<MainWebVC?>.Index?
	
	// MARK: - View Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		print("CONTAINERVC!!!!!!!!!!!!", self)
		
		for _ in 1...kDefaultNumberOfPages {
			self.dataSource.append(nil)
		}
		
		definesPresentationContext = true //
		self.safariPageController.dataSource = self
		self.safariPageController.delegate = self
		
		self.addChild(self.safariPageController)
		self.safariPageController.view.frame = self.view.bounds
		self.view.insertSubview(self.safariPageController.view, at: 0)
		self.safariPageController.didMove(toParent: self)
		
		//		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		resultsController = storyboard?.instantiateViewController(identifier: "SearchResultsController") as? SearchResultsController
		searchController = UISearchController(searchResultsController: resultsController)
		
		searchContainerViewController = UISearchContainerViewController(searchController: searchController)
		
		//		searchController.showsSearchResultsController = false
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		//		searchController.searchResultsUpdater = resultsController //!!!!!!!!!!
		searchController.searchBar.autocapitalizationType = .none
		searchController.searchBar.delegate = self
		searchController.searchBar.placeholder = "Search or enter website name"
		searchController.obscuresBackgroundDuringPresentation = false
		
		for vc in self.dataSource {
			vc?.webView.scrollView.delegate = self
			//			vc?.webView.navigationDelegate = self
			//			self.navigationController?.title = vc?.urlString //
			
		}
		
		if #available(iOS 11.0, *) {
			searchBar = searchController.searchBar
			navigationItem.searchController = searchController
			navigationItem.hidesSearchBarWhenScrolling = false
			navigationItem.prompt = nil
			//			navigationController?.toolbar.delegate = self
		}
		//		self.navigationController?.navigationBar.isHidden = true
		self.navigationController?.navigationBar.barTintColor = UIColor.white
		
		var loadedExistingURL = false //???????
		//		if let lastCommittedURLStringString = UserDefaults.standard.object(forKey: "LastCommittedURLString") as? String {
		//			self.searchBar.text = lastCommittedURLStringString
		//		}
		
		////  searchBar customization
		searchBar.showsBookmarkButton = true
		let refreshImage = UIImage(systemName: "arrow.clockwise")
		let aIcon = UIImage(systemName: "a")
		searchBar.setImage(aIcon, for: UISearchBar.Icon.search, state: UIControl.State.disabled)
		searchBar.setImage(refreshImage, for: UISearchBar.Icon.bookmark, state: UIControl.State.normal)
		searchBar.autocapitalizationType = .none
		
		let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "textformat.size"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(showPopover))
		navigationItem.leftBarButtonItem = leftBarButton
		
		self.backButton.isEnabled = false
		self.forwardButton.isEnabled = false
		
		NotificationGroup.shared.registerObserver(type: NotificationGroup.NotiType.urlUpdate, vc: self, selector: #selector(updateSearchBarText(notification:)))
		registerNewTabObserver()
		setupBackForwardObservation()
		//		setupLongPressObservation()
		
		setupCustomButtons()
		
	}
	
	//	func searchQueryFromWikiOpenSearch(query: String) {
	//		let url = URL(string: "https://en.wikipedia.org/w/api.php?")
	//		let param: Parameters = [
	//			"action" : "opensearch",
	//			"search" : query
	//		]
	//
	////		AF.request(url as! URLConvertible, method: HTTPMethod.get, parameters: param, encoding: ParameterEncoding.self, headers: <#T##HTTPHeaders?#>, interceptor: <#T##RequestInterceptor?#>)
	//		AF.request(URL(string:"https://en.wikipedia.org/w/api.php?action=opensearch&search=\(query)")!)
	//		.validate()
	//			.response {
	//
	//		}
	//
	//	}
	
	func registerNewTabObserver() {
		NotificationGroup.shared.registerObserver(type: NotificationGroup.NotiType.newTab, vc: self, selector: #selector(onNewTabNotification(notification:)))
		
		NotificationGroup.shared.registerObserver(type: NotificationGroup.NotiType.newTabsListDataUpdate, vc: self, selector: #selector(openNewTabsNotification(notification:)))
	}
	
	@objc func openNewTabsNotification(notification: Notification) {
		self.safariPageController.zoomOut(animated: true, completion: nil)
		if let urlStringArray = notification.userInfo?["newTabsURLs"] as? [String] {
			urlStringArray.forEach { (urlString) in
				let url = URL(string: urlString)
				let newTab = MainWebVC()
				
				self.dataSource.insert(newTab, at: Int(self.safariPageController.numberOfPages))
				self.safariPageController.insertPages(at: IndexSet(integer: Int(self.safariPageController.numberOfPages)), animated: true) { () -> Void in
					self.safariPageController.zoomIntoPage(at: self.safariPageController.numberOfPages - 1, animated: true, completion: nil)
					self.requestLoad(newTab, urlToRequest: url!)
				}
				self.tabsBarView.isHidden = self.safariPageController.isZoomedOut ? true : false
				
			}
			
		}
	}
	
	@objc func onNewTabNotification(notification: Notification) {
		self.safariPageController.zoomOut(animated: true, completion: nil)
		if let urlString = notification.userInfo?["newTab"] as? String {
			let newTab: MainWebVC = MainWebVC()
			let url = URL(string: urlString)
			
			
			self.dataSource.insert(newTab, at: Int(self.safariPageController.numberOfPages))
			self.safariPageController.insertPages(at: IndexSet(integer: Int(self.safariPageController.numberOfPages)), animated: true) { () -> Void in
				self.safariPageController.zoomIntoPage(at: self.safariPageController.numberOfPages - 1, animated: true, completion: nil)
				self.requestLoad(newTab, urlToRequest: url!)
			}
			self.tabsBarView.isHidden = self.safariPageController.isZoomedOut ? true : false
		}
	}
	
	//	func setupLongPressObservation() {
	//		let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongpressBarButtonItem(recognizer:)))
	//		self.tabsButton.addGestureRecognizer(recognizer)
	//	}
	//
	//	@objc func didLongpressBarButtonItem(recognizer: UILongPressGestureRecognizer) {
	//		print("Long Press!")
	//	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		//		self.safariPageController.dataSource = self
		//		self.safariPageController.delegate = self
		//		for vc in self.dataSource {
		//			vc?.webView.scrollView.delegate = self
		////			vc?.webView.navigationDelegate = self
		////			self.navigationController?.title = vc?.urlString //
		//		}
		
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated);
		self.tabsBarView.isHidden = true
		if let lastCommittedURLStringString = UserDefaults.standard.object(forKey: "LastCommittedURLString") as? String {
			self.searchBar.text = lastCommittedURLStringString
		}
		//		self.safariPageController.zoomOut(animated: true, completion: nil)
		//		if let urlObservationToken = Observables.shared.urlsObservationToken {
		//			let urlString = String(describing: urlObservationToken)
		//			self.searchBar.text = urlString
		//		}
		
		if restoredState.wasActive {
			searchController.isActive = restoredState.wasActive
			restoredState.wasActive = false
			
			if restoredState.wasFirstResponder {
				searchController.searchBar.becomeFirstResponder()
				restoredState.wasFirstResponder = false
			}
		}
		
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationGroup.shared.removeAllObserver(vc: self) //?????
	}
	
	@objc func cancelAddBookmark() {
		self.dismiss(animated: true, completion: nil)
	}
	
	@objc func updateSearchBarText(notification: Notification) {
		if let urlString = notification.userInfo?["urlString"] as? String {
			self.searchBar.text = urlString
		}
		
	}
	
	func setupBackForwardObservation() {
		if let topWebVC = self.dataSource[selectedPageIndex ?? 0] {
			Observables.shared.canGoBackObservationToken = topWebVC.webView.observe(\.canGoBack) { (object, change) in
				self.backButton.isEnabled = topWebVC.webView.canGoBack
				
				if self.backButton.isEnabled == false {
					self.backButton.imageView.tintColor = UIColor.systemGray
				} else {
					self.backButton.imageView.tintColor = UIColor.systemBlue
				}
				
			}
			
		}
		
		if let topWebVC = self.dataSource[selectedPageIndex ?? 0] {
			Observables.shared.canGoForwardObservationToken = topWebVC.webView.observe(\.canGoForward) { (object, change) in
				self.forwardButton.isEnabled = topWebVC.webView.canGoForward
				
				if self.forwardButton.isEnabled == false {
					self.forwardButton.imageView.tintColor = UIColor.systemGray
				}
				else {
					self.forwardButton.imageView.tintColor = UIColor.systemBlue
				}
				
			}
		}
		
	}
	
	func setupCustomButtons() {
		// MARK: BackButton
		backButton.tapEvent = {
			print("<- Back")
			self.dataSource[self.selectedPageIndex ?? 0]?.webView.goBack()
		}
		
		backButton.longEvent = {
			print("Back long")
			//TODO: - set the datasource to back list
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let historyNav = storyboard.instantiateViewController(identifier: "HistoryNavigationController") as HistoryNavigationController
			historyNav.entryPoint = HistoryNavigationController.entryPointType.backList
			self.navigationController?.present(historyNav, animated: true, completion: nil)
			//			historyNav.modalPresentationStyle = .currentContext
			
			
			
		}
		
		// MARK: ForwardButton
		forwardButton.tapEvent = {
			print("-> Forward")
			self.dataSource[self.selectedPageIndex ?? 0]?.webView.goForward()
		}
		
		forwardButton.longEvent = {
			print("-> Forward long")
			//TODO: - set the datasource to forward list
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let historyNav = storyboard.instantiateViewController(identifier: "HistoryNavigationController") as HistoryNavigationController
			historyNav.entryPoint = HistoryNavigationController.entryPointType.forwardList
			
			self.navigationController?.present(historyNav, animated: true, completion: nil)
		}
		
		// MARK: BookmarksButton
		bookmarksButton.tapEvent = {
			print("bookmarks")
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let bookmarkNav = storyboard.instantiateViewController(identifier: "BookmarkNav") as UINavigationController
			self.navigationController?.present(bookmarkNav, animated: true, completion: nil)
			
			if let segmentVC = bookmarkNav.children[0] as? SegmentControlVC {
				segmentVC.selectedBookmarkHandler = { urlString in
					//TODO: self.loadWebViewFromBookmarksURL(urlString: urlString)
				}
			}
		}
		
		bookmarksButton.longEvent = {
			print("bookmarks long")
			Alerts.shared.makeBookmarkAlert(viewController: self, addBookmarkHandler: { (addbookmarkAction) in
				print("Add Bookmark")
				let urlString = self.dataSource[self.selectedPageIndex ?? 0]?.webView.url?.absoluteString ?? ""
				var title = self.dataSource[self.selectedPageIndex ?? 0]?.webView.backForwardList.currentItem?.title ?? ""
				if title.isEmpty {
					title = urlString
				}
				
				let storyboard = UIStoryboard(name: "Main", bundle: nil)
				let editBookmarkVC = storyboard.instantiateViewController(identifier: "EditBookmarkVC") as! EditBookmarkVC
				let navController = UINavigationController(rootViewController: editBookmarkVC)
				
				editBookmarkVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAddBookmark))
				editBookmarkVC.caseType = .AddNewBookmark
				editBookmarkVC.bookmarkTitle = title
				editBookmarkVC.address = urlString
				self.present(navController, animated: true, completion: nil)
				
			}) { (addReadingListAction) in
				print("Add ReadingList")
				let backForwardList = self.dataSource[self.selectedPageIndex ?? 0]?.webView.backForwardList.self
				guard let currentItemUrl = backForwardList?.currentItem?.url else { return }
				guard let currentItemInitialUrl = backForwardList?.currentItem?.initialURL else { return }
				guard let currentItemTitle = backForwardList?.currentItem?.title else { return }
				guard let currentItemUrlString = backForwardList?.currentItem?.url.absoluteString else { return }
				let now = Date()
				
				let readingListDataInstance = ReadingListData(url: currentItemUrl, initialUrl: currentItemInitialUrl, title: currentItemTitle, urlString: currentItemUrlString, date: now)
				
				UserDefaultsManager.shared.insertCurrentItemToReadingList(readingListData: readingListDataInstance)
				
			}
		}
		
		// MARK: TabsButton
		tabsButton.tapEvent = {
			self.safariPageController.zoomOut(animated: true, completion: nil)
			self.navigationController?.navigationBar.isHidden = self.safariPageController.isZoomedOut ? true : false
			self.navigationController?.isToolbarHidden = self.safariPageController.isZoomedOut ? true : false
			self.tabsBarView.isHidden = self.safariPageController.isZoomedOut ? false : true
			
			for viewController in self.dataSource {
				viewController?.setHeaderVisible(self.safariPageController.isZoomedOut, animated: true)
				viewController?.blockUserInteractionWhenOpeningTab(self.safariPageController.isZoomedOut)
			}
			
		}
		
		tabsButton.longEvent = {
			print("Tabs Long")
			Alerts.shared.makeTabAlert(viewController: self, closeThisTabHandler: { (closeAction) in
				print("Close Tab")
				self.viewControllerDidRequestDelete(self.dataSource[self.selectedPageIndex ?? 0] ?? MainWebVC())
			}, closeAllTabsHandler: { (closeAllAction) in
				print("Close All Tabs")
				for allVCs in self.dataSource {
					self.viewControllerDidRequestDelete(allVCs ?? MainWebVC())
				}
			}) { (newTabAction) in
				print("New Tab")
				//TODO: need to zoom out -> zoom into new tab first.
				self.safariPageController.zoomOut(animated: true, completion: nil)
				self.dataSource.insert(nil, at: Int(self.safariPageController.numberOfPages))
				self.safariPageController.insertPages(at: IndexSet(integer: Int(self.safariPageController.numberOfPages)), animated: true) { () -> Void in
					self.safariPageController.zoomIntoPage(at: self.safariPageController.numberOfPages - 1, animated: true, completion: nil)
				}
				self.tabsBarView.isHidden = self.safariPageController.isZoomedOut ? true : false
			}
			
			
		}
		
		
	}
	
	@objc func goBack() {
		print("<- Back")
		self.dataSource[self.selectedPageIndex ?? 0]?.webView.goBack()
	}
	
	@objc func goForward() {
		print("<- Forward")
		self.dataSource[self.selectedPageIndex ?? 0]?.webView.goForward()
	}
	
	//// Delete later
	//	@IBAction func backButton(_ sender: UIBarButtonItem) {
	//		self.dataSource[selectedPageIndex ?? 0]?.webView.goBack()
	//	}
	//
	//	@IBAction func forwardButton(_ sender: UIBarButtonItem) {
	//		self.dataSource[selectedPageIndex ?? 0]?.webView.goForward()
	//	}
	
	@IBAction func shareButton(_ sender: UIBarButtonItem) {
		if let link = NSURL(string: self.searchBar.text!) {
			let objectsToShare = [link] as [Any]
			let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
			activityVC.excludedActivityTypes = []
			self.present(activityVC, animated: true, completion: nil)
		}
	}
	
	//// DeleteLater
	//	@IBAction func tabsBarButton(_ sender: UIBarButtonItem) {
	//		self.safariPageController.zoomOut(animated: true, completion: nil)
	//		self.navigationController?.navigationBar.isHidden = self.safariPageController.isZoomedOut ? true : false
	//		self.navigationController?.isToolbarHidden = self.safariPageController.isZoomedOut ? true : false
	//		self.tabsBarView.isHidden = self.safariPageController.isZoomedOut ? false : true
	//
	//		for viewController in self.dataSource {
	//			viewController?.setHeaderVisible(self.safariPageController.isZoomedOut, animated: true)
	//			viewController?.blockUserInteractionWhenOpeningTab(self.safariPageController.isZoomedOut)
	//		}
	//
	//
	////		guard let touch = event.allTouches?.first else {
	////			return
	////		}
	////
	////		if touch.tapCount == 1 {
	////			self.safariPageController.zoomOut(animated: true, completion: nil)
	////			self.navigationController?.navigationBar.isHidden = self.safariPageController.isZoomedOut ? true : false
	////			self.navigationController?.isToolbarHidden = self.safariPageController.isZoomedOut ? true : false
	////			self.tabsBarView.isHidden = self.safariPageController.isZoomedOut ? false : true
	////
	////			for viewController in self.dataSource {
	////				viewController?.setHeaderVisible(self.safariPageController.isZoomedOut, animated: true)
	////				viewController?.blockUserInteractionWhenOpeningTab(self.safariPageController.isZoomedOut)
	////			}
	////		}
	////		else if touch.tapCount == 0 {
	////			print("Tab Long touch??")
	////		}
	//
	//	}
	
	
	
	@IBAction func doneButtonTap(_ sender: UIButton) {
		//		self.toggleZoomWithPageIndex(self.safariPageController.currentPage)
		if self.safariPageController.isZoomedOut {
			self.safariPageController.zoomIntoPage(at: self.safariPageController.currentPage, animated: true, completion: nil)
			for viewController in self.dataSource {
				viewController?.setHeaderVisible(self.safariPageController.isZoomedOut, animated: true)
				viewController?.blockUserInteractionWhenOpeningTab(self.safariPageController.isZoomedOut)
			}
		}
		self.tabsBarView.isHidden = self.safariPageController.isZoomedOut ? false : true
	}
	
	@IBAction func addButtonTap(_ sender: UIButton) {
		self.dataSource.insert(nil, at: Int(self.safariPageController.numberOfPages))
		self.safariPageController.insertPages(at: IndexSet(integer: Int(self.safariPageController.numberOfPages)), animated: true) { () -> Void in
			//			self.toggleZoomWithPageIndex(self.safariPageController.numberOfPages - 1)
			self.safariPageController.zoomIntoPage(at: self.safariPageController.numberOfPages - 1, animated: true, completion: nil)
		}
		self.tabsBarView.isHidden = self.safariPageController.isZoomedOut ? true : false
		
	}
	
	
	// MARK: - numberofpages
	func numberOfPages(in pageController: SCSafariPageController!) -> UInt {
		return UInt(self.dataSource.count)
	}
	
	func pageController(_ pageController: SCSafariPageController!, viewControllerForPageAt index: UInt) -> UIViewController! {
		var viewController = self.dataSource[Int(index)]
		
		if viewController == nil {
			viewController = MainWebVC()
			viewController?.delegate = self
			self.dataSource[Int(index)] = viewController
		}
		
		viewController?.setHeaderVisible(self.safariPageController.isZoomedOut, animated: false)
		viewController?.blockUserInteractionWhenOpeningTab(self.safariPageController.isZoomedOut)
		
		return viewController
	}
	
	func pageController(_ pageController: SCSafariPageController!, willDeletePageAt pageIndex: UInt) {
		self.dataSource.remove(at: Int(pageIndex))
	}
	
	// MARK: - SCViewControllerDelegate
	
	func viewControllerDidReceiveTap(_ viewController: MainWebVC) {
		//
		//		if !self.safariPageController.isZoomedOut {
		//			viewController.webView.isUserInteractionEnabled = true //
		//			return
		//		}
		//		let pageIndex = self.dataSource.firstIndex{$0 === viewController}
		//		selectedPageIndex = self.dataSource.firstIndex{$0 === viewController}
		//
		//		self.tabsBarView.isHidden = self.safariPageController.isZoomedOut ? false : true //
		//		for viewController in self.dataSource {
		//			viewController?.setHeaderVisible(self.safariPageController.isZoomedOut, animated: true)
		//			viewController?.blockUserInteractionWhenOpeningTab(self.safariPageController.isZoomedOut)
		//		}
		
		if self.safariPageController.isZoomedOut { //zoomed out
			let pageIndex = self.dataSource.firstIndex{$0 === viewController}
			selectedPageIndex = self.dataSource.firstIndex{$0 === viewController}
			//			self.safariPageController.zoomIntoPage(at: UInt(pageIndex!), animated: true, completion: nil)
			self.safariPageController.zoomIntoPage(at: UInt(pageIndex!), animated: true) {
				self.tabsBarView.isHidden = true
				viewController.webView.isUserInteractionEnabled = true
			}
			
			
			//			self.safariPageController.zoomIntoPage(at: UInt(selectedPageIndex!), animated: true) {
			//				self.tabsBarView.isHidden = true
			//				viewController.webView.isUserInteractionEnabled = true
			//			}
			
			
			
		}
		else { //zoomed in
			viewController.webView.isUserInteractionEnabled = true
			self.tabsBarView.isHidden = false
		}
		
		//		self.toggleZoomWithPageIndex(UInt(pageIndex!))
		//		self.safariPageController.zoomIntoPage(at: UInt(pageIndex!), animated: true, completion: nil)
	}
	
	func requestLoad(_ viewController: MainWebVC, urlToRequest: URL) {
		let pageIndex = self.dataSource.firstIndex{$0 === viewController}
		let request = URLRequest(url: urlToRequest)
		viewController.addresslb.text = urlToRequest.absoluteString
		self.dataSource[pageIndex!]?.webView.load(request)
	}
	
	func viewControllerDidRequestDelete(_ viewController: MainWebVC) {
		let pageIndex = self.dataSource.firstIndex{$0 === viewController}!
		
		self.dataSource.remove(at: pageIndex)
		self.safariPageController.deletePages(at: IndexSet(integer: pageIndex), animated: true, completion: nil)
	}
	
	@objc func showPopover() {
		print("show Popover")
		presentPopoverWithActions(actions: [
			addToFavoritesAction(),
			shareAction(),
			toggleContentAction(),
			loadStartPageAction(),
			cancelAction()
		])
	}
	
	
	func presentPopoverWithActions(actions: [UIAlertAction]) {
		let alertController = UIAlertController(title: nil, message: nil
			, preferredStyle: UIAlertController.Style.actionSheet)
		for action in actions {
			alertController.addAction(action)
		}
		if let popoverController = alertController.popoverPresentationController {
			if let leftBarButtonItem = navigationItem.leftBarButtonItem {
				popoverController.sourceRect = leftBarButtonItem.accessibilityFrame
			}
			
			//			popoverController.sourceRect = navigationItem.leftBarButtonItem?.accessibilityFrame!
			popoverController.sourceView = self.view
			popoverController.permittedArrowDirections = .up
		}
		self.present(alertController, animated: true, completion: nil)
		
	}
	
	func addToFavoritesAction() -> UIAlertAction {
		return Alerts.ActionType.addToFavorites.makeAlertActions { (action) -> (Void) in
			print("Add To Favorites?")
			
			let urlString = self.dataSource[self.selectedPageIndex ?? 0]?.webView.url?.absoluteString ?? ""
			var title = self.dataSource[self.selectedPageIndex ?? 0]?.webView.backForwardList.currentItem?.title ?? ""
			if title.isEmpty {
				title = urlString
			}
			
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let editBookmarkVC = storyboard.instantiateViewController(identifier: "EditBookmarkVC") as! EditBookmarkVC
			let navController = UINavigationController(rootViewController: editBookmarkVC)
			
			editBookmarkVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAddBookmark))
			editBookmarkVC.caseType = .AddNewBookmark
			editBookmarkVC.bookmarkTitle = title
			editBookmarkVC.address = urlString
			self.present(navController, animated: true, completion: nil)
		}
	}
	
	func shareAction() -> UIAlertAction {
		return Alerts.ActionType.share.makeAlertActions { (action) -> (Void) in
			if let link = NSURL(string: self.searchBar.text!) {
				let objectsToShare = [link] as [Any]
				let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
				activityVC.excludedActivityTypes = []
				self.present(activityVC, animated: true, completion: nil)
			}
		}
	}
	
	func toggleContentAction() -> UIAlertAction {
		//FIXME: not working properly
		let requestMobileSite = Observables.shared.currentContentMode == .desktop
		let title = requestMobileSite ? "Request Mobile Site" : "Request Desktop Site"
		return UIAlertAction(title: title, style: UIAlertAction.Style.default) { (alert: UIAlertAction!) -> Void in
			if let url = self.dataSource[self.selectedPageIndex ?? 0]?.webView.url {
				let requestContentMode = requestMobileSite ? WKWebpagePreferences.ContentMode.mobile : WKWebpagePreferences.ContentMode.desktop
				if url.scheme != "file" {
					if let hostName = url.host {
						Observables.shared.contentModeToRequestForHost[hostName] = requestContentMode
					}
				} else {
					Observables.shared.contentModeToRequestForHost[hostNameForLocalFile] = requestContentMode
				}
				self.dataSource[self.selectedPageIndex ?? 0]?.webView.reloadFromOrigin()
			}
		}
		
	}
	
	func loadStartPageAction() -> UIAlertAction {
		return Alerts.ActionType.loadStartPage.makeAlertActions { (action) -> (Void) in
			print("load start page")
			self.dataSource[self.selectedPageIndex ?? 0]?.loadStartPage()
		}
	}
	
	func cancelAction() -> UIAlertAction {
		return Alerts.ActionType.cancel.makeAlertActions { (action) -> (Void) in
			print("Canceled")
		}
	}
	
	
	// MARK: Private
	//	fileprivate func ZoomWithPageIndex(_ pageIndex:UInt) {
	//		if self.safariPageController.isZoomedOut {
	//			self.safariPageController.zoomIntoPage(at: pageIndex, animated: true, completion: nil)
	//		} else {
	//			self.safariPageController.zoomOut(animated: true, completion: nil)
	//		}
	//
	//		for viewController in self.dataSource {
	//			viewController?.setHeaderVisible(self.safariPageController.isZoomedOut, animated: true)
	//			viewController?.blockUserInteractionWhenOpeningTab(self.safariPageController.isZoomedOut)
	//		}
	//
	//		UIView.animate(withDuration: 0.25) { () -> Void in
	//			self.addButton.alpha = (self.safariPageController.isZoomedOut ? 1.0 : 0.0)
	//		}
	//
	//	}
	
	
	
	
	
}

// MARK: - UISearchControllerDelegate
extension ContainerVC: UISearchControllerDelegate {
	
	func presentSearchController(_ searchController: UISearchController) {
		print("presentSearchController")
		//		self.searchController.showsSearchResultsController = true
	}
	
	func willPresentSearchController(_ searchController: UISearchController) {
		print("willPresentSearchController")
		
		//		searchController.showsSearchResultsController = false
	}
	
	func didPresentSearchController(_ searchController: UISearchController) {
		print("didPresentSearchController")
		
	}
	
	func willDismissSearchController(_ searchController: UISearchController) {
		print("willDismissSearchController")
		
	}
	
	func didDismissSearchController(_ searchController: UISearchController) {
		print("didDismissSearchController")
		
	}
	
}

// MARK: - UISearchResultsUpdating
extension ContainerVC: UISearchResultsUpdating {

	func searchContentForText(_ searchText: String) {
		// Strip out all the leading and trailing spaces.
		let whitespaceCharacterSet = CharacterSet.whitespaces
		let strippedString = searchText.trimmingCharacters(in: whitespaceCharacterSet)
		//		let searchItems = strippedString.components(separatedBy: " ") as [String]
		//		searchQueryFromWikiOpenSearch(query: strippedString)
		
		let url = URL(string: "https://en.wikipedia.org/w/api.php?")!
		let param: Parameters = [
			"action" : "opensearch",
			"search" : searchText
		]
		
		var headers = HTTPHeaders()
		headers = [
			//			"Content-Type" : "text/html; charset=UTF-8",
			//			"Content-Type" : "application/x-www-form-urlencoded",
			"Content-Type" : "application/json",
			"Accept": "multipart/form-data"
		]
		AF.request(url, method: .get, parameters: param, headers: headers)
			.validate()
			.response { (response) in
				if let data = response.data {
					do {
						if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .allowFragments]) as? [Any] {
							print("json!!!", json)
							
							if let suggestionsArray = json[1] ?? nil {
								print("autocompleteSuggestions!!!")
								print(suggestionsArray)
//								self.resultsController.wikipediaData = suggestionsArray as! [String]
								self.resultsController.filteredWikipediaData = suggestionsArray as! [String]
								//TODO: - do I need to put this inside dispatch queue????
								self.resultsController.tableView.reloadData()
							}
							
							if let suggestionsURLArray = json[3] ?? nil {
								print("autocompletionSuggestionsURLs!!!!")
								print(suggestionsURLArray)
//								self.resultsController.wikipediaUrlStrings = suggestionsURLArray as! [String]
								self.resultsController.filteredWikipediaURLStrings = suggestionsURLArray as! [String]
								//TODO: - do I need to put this inside dispatch queue????
								self.resultsController.tableView.reloadData()
							}
						}
					}
					catch {
						print("ERRORFEFEFE", error)
						//TODO: - How should I handle this error here if there is no search text??
					}
				}
		}

	}
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		print("searchBarShouldBeginEditing")
		
		DispatchQueue.main.async {
			UIApplication.shared.sendAction(#selector(searchBar.selectAll(_:)), to: nil, from: nil, for: nil)
		}
		
		self.addChild(childBookmarkVC)
		childBookmarkVC.navigationItem.searchController?.searchBar.isHidden = true
		self.view.addSubview(childBookmarkVC.view)
		
		return true
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		print("searchBarTextDidBeginEditing")
		if self.childBookmarkVC.view != nil {
			self.childBookmarkVC.view.removeFromSuperview()
		}
	}
	
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		print("searchBarShouldEndEditing")
		searchBar.endEditing(true)
		searchBar.resignFirstResponder()
		return true
	}
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		print("searchBarTextDidEndEditing")
		guard var urlString = searchBar.text?.lowercased() else {
			return
		}
		if !urlString.contains("://") {
			if urlString.contains("localhost") || urlString.contains("127.0.0.1") {
				urlString = "http://" + urlString
			} else {
				urlString = "https://" + urlString
			}
		}
		
		urlToRequest = URL(string: urlString)
		
		/// MainWebView의 protocol 중 하나인 requestLoad 는 현재 선택된 웹뷰 (selectedPageIndex) 를 가지고 그 해당 웹뷰에 URL 을 보낸다. 만약에 선택된 웹뷰탭이 없다면 0번째 웹뷰에 urlRequest를 보낸다.
		requestLoad(self.dataSource[selectedPageIndex ?? 0] ?? MainWebVC(), urlToRequest: urlToRequest!)
		
		//		let targetUrl = URL(string: urlString)
		//		let urlRequest = URLRequest(url: targetUrl!)
		//		print(self.safariPageController.loadedViewControllers)
		//		let pageIndex = self.dataSource.firstIndex{$0 === viewController}
		//-----------
		//		self.dataSource[UInt(self.selectedPageIndex)]
		//---------
		//		if let toppickedvc = self.dataSource.first {
		//			if let targetUrl = URL(string: urlString) {
		//				toppickedvc?.webView.load(URLRequest(url: targetUrl))
		//			}
		//		}
		//---------------
		//		if webView.url?.absoluteString == urlString {
		//			return
		//		}
		//
		//		if let targetUrl = URL(string: urlString) {
		//			webView.load(URLRequest(url: targetUrl))
		//		}
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		print("searchBarSearchButtonClicked")
		searchBarTextDidEndEditing(searchBar)
		self.searchBar.resignFirstResponder()
		if self.childBookmarkVC.view != nil {
			self.childBookmarkVC.view.removeFromSuperview()
		}
		self.searchController.showsSearchResultsController = false
	}
	
	/* ---------- [FROM TableSearch] ---------- */
	private func findMatches(searchString: String, keyPath: String) -> NSCompoundPredicate {
		
		var searchItemsPredicate = [NSPredicate]()
		
		// title matching
		//		let titleExpression = NSExpression(forKeyPath: Product.ExpressionKeys.title.rawValue)
		let titleExpression = NSExpression(forKeyPath: keyPath)
		
		let searchStringExpression = NSExpression(forConstantValue: searchString)
		
		let titleSearchComparisonPredicate = NSComparisonPredicate(leftExpression: titleExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: [.caseInsensitive, .diacriticInsensitive])
		
		searchItemsPredicate.append(titleSearchComparisonPredicate)
		
		var finalCompoundPredicate: NSCompoundPredicate!
		
		finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: searchItemsPredicate)
		
		return finalCompoundPredicate
	}
	
	
	/* -------------------- */
	
	func updateSearchResults(for searchController: UISearchController) {
		searchBar = searchController.searchBar
		//		guard let text = searchController.searchBar.text else { return }
		
		// Update the filtered array based on the search text.
		let wikipediaSearchResults = resultsController.wikipediaData
		let bookmarkSearchResults = resultsController.bookmarkData
		let historySearchResults = resultsController.historyData
		let readingListSearchResults = resultsController.readingListData
		
		// Strip out all the leading and trailing spaces.
		let whitespaceCharacterSet = CharacterSet.whitespaces
		let strippedString = searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
		let searchItems = strippedString.components(separatedBy: " ") as [String]
		
		/* ---------- [Bookmark] ---------- */
		let andMatchBookmarkPredicates: [NSPredicate] = searchItems.map { searchString in
//			findMatches(searchString: searchString, keyPath: BookmarkData.expressionKeys.titleString.rawValue)
			findMatches(searchString: searchString, keyPath: BookmarkData.expressionKeys.urlString.rawValue)
		}
		
		let finalCompoundBookmarkPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchBookmarkPredicates)
		
		//		for item in bookmarkSearchResults { // 폴더가 아닌지를 체크 하기 위해??
		//			if !item.isFolder {
		//				let filteredBookmarkResults = bookmarkSearchResults.filter { (bookmarkData) -> Bool in
		//					finalCompoundBookmarkPredicate.evaluate(with: bookmarkData )
		//				}
		//			}
		//		}
		
		//		let filteredBookmarkResults  = bookmarkSearchResults.filter { (bookmarkData) -> Bool in
		////			bookmarkData.child.count == 0 && finalCompoundBookmarkPredicate.evaluate(with: bookmarkData)
		//			for item in bookmarkData.child {
		//				return item.child.isEmpty && finalCompoundBookmarkPredicate.evaluate(with: item)
		//			}
		//
		//		}
		/* ---------- [Bookmark] ---------- */
		var filteredBookmarkResults: [BookmarkData] = []
		for bookmarkItem in bookmarkSearchResults {
			if bookmarkItem.child.isEmpty && !bookmarkItem.isFolder {
				filteredBookmarkResults = bookmarkSearchResults.filter { (bookmarkData) -> Bool in
					finalCompoundBookmarkPredicate.evaluate(with: bookmarkData)
				}
			}
		}
		
		
		/* ---------- [History] ---------- */
		// Build all the "AND" expressions for each value in searchString.
		let andMatchHistoryPredicates: [NSPredicate] = searchItems.map { searchString in
//			findMatches(searchString: searchString, keyPath: HistoryData.expressionKeys.title.rawValue)
			findMatches(searchString: searchString, keyPath: HistoryData.expressionKeys.urlString.rawValue)
		}
		
		// Match up the fields of the Product object.
		let finalCompoundHistoryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchHistoryPredicates)
		
		let filteredHistoryResults = historySearchResults.filter { finalCompoundHistoryPredicate.evaluate(with: $0)}
		
		// Apply the filtered results to the search results table.
		//		if let resultsController = self.searchController.searchResultsController as? SearchResultsController {
		//			resultsController.filteredHistoryData = filteredResults
		//			resultsController.tableView.reloadData()
		//		}
		
		/* ---------- [ReadingList] ---------- */
		
		let andMatchReadingListPredicates: [NSPredicate] = searchItems.map { searchString in
//			findMatches(searchString: searchString, keyPath: ReadingListData.expressionkeys.title.rawValue)
			findMatches(searchString: searchString, keyPath: ReadingListData.expressionkeys.urlString.rawValue)
		}
		
		let finalCompoundReadingListPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchReadingListPredicates)
		
		let filteredReadingListResults = readingListSearchResults.filter { finalCompoundReadingListPredicate.evaluate(with: $0)}
		
		/* ---------- [On this page] ---------- */
		
		resultsController.originalData = resultsController.onThisPageData
		
		self.searchController = searchController
		resultsController.searchText = searchController.searchBar.text!
		resultsController.isSearchBarEmpty = { searchController.searchBar.text?.isEmpty ?? true }()
		resultsController.isFiltering = { searchController.isActive && !(resultsController.isSearchBarEmpty ?? true)}()
		
		DispatchQueue.main.async {
//			self.filterContentForSearchText(self.resultsController.searchText!)
//			self.resultsController.filteredWikipediaData =
			self.resultsController.filteredBookmarkData = filteredBookmarkResults
			self.resultsController.filteredHistoryData = filteredHistoryResults
			self.resultsController.filteredReadingListData = filteredReadingListResults
			self.resultsController.tableView.reloadData()
		}
		
	}
	
	func filterContentForSearchText(_ searchText: String) {
		resultsController.filteredData = resultsController.originalData.filter( { (string) -> Bool in
			Jamo.getJamo(string.lowercased()).contains(Jamo.getJamo(searchText.lowercased()))
		})
		
		resultsController.tableView.reloadData()
	}
	
}

// MARK: - UISearchBarDelegate
extension ContainerVC: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		print("textDidChange")
		
		self.searchController.showsSearchResultsController = true
		filterContentForSearchText(searchText)
		searchContentForText(searchText)
		resultsController.tableView.reloadData()
	}
	
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.endEditing(true)
		searchBar.resignFirstResponder()
		resignFirstResponder()
		//		hideKeyboardWhenTappedAround()
		self.searchController.showsSearchResultsController = false
		if self.childBookmarkVC.view != nil {
			self.childBookmarkVC.view.removeFromSuperview()
		}
	}
	
	
	func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
		print("bookmark button clicked")
		if let topWebVC = self.dataSource[selectedPageIndex ?? 0] {
			topWebVC.webView.reload()
		}
		
	}
	
	
}

// MARK: - UIScrollViewDelegate
extension ContainerVC: UIScrollViewDelegate {
	/// 웹뷰를 스크롤 할 때 상위의 navigation bar (search bar) 와 하단의 toolbar 가 위 아래로 사라지기 위해 사용
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
		if(velocity.y>0) {
			//Code will work without the animation block.I am using animation block incase if you want to set any delay to it.
			UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: {
				self.navigationController?.setNavigationBarHidden(true, animated: true)
				self.navigationController?.setToolbarHidden(true, animated: true)
				//				self.navigationController?.navigationItem.hidesSearchBarWhenScrolling = false
				//				self.navigationController?.toolbar.isHidden = true
				
				print("Hide")
			}, completion: nil)
			
		} else {
			UIView.animate(withDuration: 0.1, delay: 0, options: UIView.AnimationOptions(), animations: {
				self.navigationController?.setNavigationBarHidden(false, animated: true)
				self.navigationController?.setToolbarHidden(false, animated: true)
				print("Unhide")
			}, completion: nil)
		}
	}
	
}

// MARK: - UIToolbarDelegate
extension ContainerVC: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return UIBarPosition.bottom
	}
}


// MARK: - Restore
extension ContainerVC {
	/// State restoration values
	enum RestorationKeys: String {
		case viewControllerTitle
		case searchControllerIsActive
		case searchBarText
		case searchBarIsFirstResponder
		case selectedScope
	}
	
	/// State items to be restored in viewDidAppear()
	struct SearchControllerRestorableState {
		var wasActive = false
		var wasFirstResponder = false
	}
	
	override func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		
		// Encode the view state so it can be restored later.
		
		// Encode the title.
		coder.encode(navigationItem.title!, forKey: RestorationKeys.viewControllerTitle.rawValue)
		
		// Encode the search controller's active state.
		coder.encode(searchController.isActive, forKey: RestorationKeys.searchControllerIsActive.rawValue)
		
		// Encode the first responder status.
		coder.encode(searchController.searchBar.isFirstResponder, forKey: RestorationKeys.searchBarIsFirstResponder.rawValue)
		
		// Encode the first responder status (scope button)
		//		coder.encode(searchController.searchBar.selectedScopeButtonIndex, forKey: RestorationKeys.selectedScope.rawValue)
		
		// Encode the search bar text.
		coder.encode(searchController.searchBar.text, forKey: RestorationKeys.searchBarText.rawValue)
		
	}
	
	override func decodeRestorableState(with coder: NSCoder) {
		super.decodeRestorableState(with: coder)
		
		// Restore the title.
		guard let decodedTitle = coder.decodeObject(forKey: RestorationKeys.viewControllerTitle.rawValue) as? String else {
			fatalError("A title did not exist. Handle this gracefully?????")
		}
		
		navigationItem.title! = decodedTitle
		
		/** Retore the active and first responder state: We can't make the searchController active here since it's not part of the view hierarchy yet. instead we do it in the viewDidAppear.
		*/
		
		restoredState.wasActive = coder.decodeBool(forKey: RestorationKeys.searchControllerIsActive.rawValue)
		restoredState.wasFirstResponder = coder.decodeBool(forKey: RestorationKeys.searchBarIsFirstResponder.rawValue)
		
		// Restore the scope bar selection.
		//		searchController.searchBar.selectedScopeButtonIndex = coder.decodeInteger(forKey: RestorationKeys.selectedScope.rawValue)
		
		searchController.searchBar.text = coder.decodeObject(forKey: RestorationKeys.searchBarText.rawValue) as? String
	}
	
}
