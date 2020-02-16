//
//  SegmentControlVC.swift
//  Safari
//
//  Created by 변재우 on 20200212//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit
	
class SegmentControlVC: UIViewController {
	
	@IBAction func done(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBOutlet weak var topToolBar: UIToolbar!
	
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	
	@IBOutlet weak var contentView: UIView!
	
	var selectedBookmarkHandler: ((_ urlString: String?) -> ())?
	
	lazy var bookmarksViewController: BookmarkVC = {
		//Load Storyboard
		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
		//Instantiate VC
		var bookmarkVC = storyboard.instantiateViewController(identifier: "BookmarkVC") as! BookmarkVC
		bookmarkVC.title = "Bookmarks"
		// Add VC as ChildVC
		self.add(asChildViewController: bookmarkVC)
		
//		bookmarkVC.completionHandler = { urlString in
//			if let completionHandler = self.selectedBookmarkHandler {
//				completionHandler(urlString)
//			}
//		}
//		bookmarkVC.completionHandler = self.selectedBookmarkHandler
		
		return bookmarkVC
	}()
	
	lazy var readingListViewController: ReadingListVC = {
		//Load Storyboard
		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
		//Instantiate VC
		var viewController = storyboard.instantiateViewController(identifier: "ReadingListVC") as! ReadingListVC
		// Add VC as ChildVC
		self.add(asChildViewController: viewController)
		return viewController
	}()
	
	lazy var historyViewController: HistoryVC = {
		//Load Storyboard
		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
		//Instantiate VC
		var viewController = storyboard.instantiateViewController(identifier: "HistoryVC") as! HistoryVC
		// Add VC as ChildVC
		self.add(asChildViewController: viewController)
		return viewController
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Bookmarks"
		///
		self.navigationController?.navigationBar.barTintColor = UIColor.blue
		self.navigationController?.isNavigationBarHidden = false
		self.navigationController?.navigationBar.isHidden = false
		
		self.topToolBar.delegate = self
		
		setupView()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	func setupView() {
		setupSegmentedControl()
		updateView()
	}
	
	func updateView() {
		if segmentedControl.selectedSegmentIndex == 0 {
			remove(asChildViewController: readingListViewController)
			remove(asChildViewController: historyViewController)
			add(asChildViewController: bookmarksViewController)
			self.title = bookmarksViewController.title
			
		}
		else if segmentedControl.selectedSegmentIndex == 1 {
			remove(asChildViewController: bookmarksViewController)
			remove(asChildViewController: historyViewController)
			add(asChildViewController: readingListViewController)
			self.title = readingListViewController.title
		}
		else {
			remove(asChildViewController: bookmarksViewController)
			remove(asChildViewController: readingListViewController)
			add(asChildViewController: historyViewController)
			self.title = historyViewController.title
		}
	}
	
	func setupSegmentedControl() {
		// Configure Segmented Control
		segmentedControl.removeAllSegments()
		segmentedControl.insertSegment(with: UIImage(systemName: "book"), at: 0, animated: true)
		segmentedControl.insertSegment(with: UIImage(systemName: "eyeglasses"), at: 1, animated: true)
		segmentedControl.insertSegment(with: UIImage(systemName: "clock"), at: 2, animated: true)
		segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
		
		// Select First Segment
		segmentedControl.selectedSegmentIndex = 0
	}
	
	private func add(asChildViewController viewController: UIViewController) {
		// Add Child View Controller
		addChild(viewController)
		
		//add Child View as Subview
		self.contentView.addSubview(viewController.view)
		//		view.addSubview(viewController.view)
		
		//configure Child View
		viewController.view.bounds = view.bounds //
		viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.toolbarItems = viewController.toolbarItems
		
		//Notify Child ViewController
		viewController.didMove(toParent: self)
	}
	
	private func remove(asChildViewController viewController: UIViewController) {
		//Notify Child ViewController
		viewController.willMove(toParent: nil)
		
		//Remove Child View from Superview
		viewController.view.removeFromSuperview()
		
		//Notify Child View Controller
		viewController.removeFromParent()
	}
	
	@objc func selectionDidChange(_ sender: UISegmentedControl) {
		updateView()
	}
	
	//MARK: - PreviewActionItems
//	override var previewActionItems: [UIPreviewActionItem] {
//		let addBookmark = UIPreviewAction(title: "Add Bookmark", style: UIPreviewAction.Style.default) { [unowned self](action, viewcontroller) in
//			print("addBookmark pressed")
//		}
//
//		let addToReadingList = UIPreviewAction(title: "Add to Reading Llist", style: UIPreviewAction.Style.default) { [unowned self](previewaction, viewcontroller) in
//			print("addtoreadinglist pressed")
//		}
//
//		let cancelAction = UIPreviewAction(title: "Cancel", style: UIPreviewAction.Style.destructive) { [unowned self](action, vc) in
//			print("cancel pressed")
//		}
//
//		return [addBookmark, addToReadingList, cancelAction]
//	}
	
	
	
}

extension SegmentControlVC: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return UIBarPosition.topAttached
	}
}
