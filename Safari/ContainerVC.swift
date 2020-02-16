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
	
	
	
	lazy var searchBar = UISearchBar(frame: CGRect.zero)
	let searchController = UISearchController(searchResultsController: nil) //TODO: Make searchResultsController later
	
	
	var urlToRequest: URL?
	var selectedPageIndex: Array<MainWebVC?>.Index?
	
	// MARK: - View Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		for _ in 1...kDefaultNumberOfPages {
			self.dataSource.append(nil)
		}
		
		self.safariPageController.dataSource = self
		self.safariPageController.delegate = self
		
		self.addChild(self.safariPageController)
		self.safariPageController.view.frame = self.view.bounds
		self.view.insertSubview(self.safariPageController.view, at: 0)
		self.safariPageController.didMove(toParent: self)
		
		searchController.delegate = self
		searchController.searchResultsUpdater = self
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
		
		
		////  searchBar customization
		searchBar.showsBookmarkButton = true
		let refreshImage = UIImage(systemName: "arrow.clockwise")
		let aIcon = UIImage(systemName: "a")
		searchBar.setImage(aIcon, for: UISearchBar.Icon.search, state: UIControl.State.disabled)
		searchBar.setImage(refreshImage, for: UISearchBar.Icon.bookmark, state: UIControl.State.normal)
		searchBar.autocapitalizationType = .none
		
		let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "textformat.size"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(showPopover))
		navigationItem.leftBarButtonItem = leftBarButton
		
		setupBackForwardObservation()
//		setupLongPressObservation()
		
		setupCustomButtons()
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
		
//		self.safariPageController.zoomOut(animated: true, completion: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	func setupBackForwardObservation() {
		if let topWebVC = self.dataSource[selectedPageIndex ?? 0] {
			Observables.shared.canGoBackObservationToken = topWebVC.webView.observe(\.canGoBack) { (object, change) in
				self.backButton.isEnabled = topWebVC.webView.canGoBack
			}
			
		}
		
		if let topWebVC = self.dataSource[selectedPageIndex ?? 0] {
			Observables.shared.canGoForwardObservationToken = topWebVC.webView.observe(\.canGoForward) { (object, change) in
				self.forwardButton.isEnabled = topWebVC.webView.canGoForward
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
			//TODO: implement later
		}
		
		// MARK: ForwardButton
		forwardButton.tapEvent = {
			print("-> Forward")
			self.dataSource[self.selectedPageIndex ?? 0]?.webView.goForward()
		}
		
		forwardButton.longEvent = {
			print("-> Forward long")
			//TODO: implement later
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
			//TODO: implement later
			print("bookmarks long")
			Alerts.shared.makeBookmarkAlert(viewController: self, addBookmarkHandler: { (addbookmarkAction) in
				print("Add Bookmark")
			}) { (addReadingListAction) in
				print("Add ReadingList")
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
				print("close????")
				self.viewControllerDidRequestDelete(self.dataSource[self.selectedPageIndex ?? 0] ?? MainWebVC())
			}, closeAllTabsHandler: { (closeAllAction) in
				print("Close All??")
				
			}) { (newTabAction) in
				print("newTab ?????")
				
				//TODO: need to zoom out -> zoom into new tab first.
				self.dataSource.insert(nil, at: Int(self.safariPageController.numberOfPages))
						self.safariPageController.insertPages(at: IndexSet(integer: Int(self.safariPageController.numberOfPages)), animated: true) { () -> Void in
				//			self.toggleZoomWithPageIndex(self.safariPageController.numberOfPages - 1)
							self.safariPageController.zoomIntoPage(at: self.safariPageController.numberOfPages - 1, animated: true, completion: nil)
						}
						self.tabsBarView.isHidden = self.safariPageController.isZoomedOut ? true : false
			}
			
			
		}
		
		
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
			//TODO: add to favorites
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
	
}

// MARK: - UISearchResultsUpdating
extension ContainerVC: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		searchBar = searchController.searchBar
	}
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		
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
	
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		searchBar.endEditing(true)
		searchBar.resignFirstResponder()
		return true
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBarTextDidEndEditing(searchBar)
		self.searchBar.resignFirstResponder()
	}

	
	
}

// MARK: - UISearchBarDelegate
extension ContainerVC: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		print("textDidChange")
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.endEditing(true)
		searchBar.resignFirstResponder()
		resignFirstResponder()
//		hideKeyboardWhenTappedAround()
	}
	
	func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
		print("bookmark button clicked")
//		self.webView.reload()
		
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
