//
//  Alerts.swift
//  Safari
//
//  Created by 변재우 on 20200211//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit


class Alerts {
	static let shared = Alerts()
	
	var delegate: Alerts?
	
	public enum ActionType {
		case addToFavorites
		case share
		case requestDesktopSite
		case loadStartPage
		case cancel
		
		case addBookmark
		case addReadingList
		
		case closeTab
		case closeAllTabs
		case newTab
		
		
		func getTitle() -> String {
			switch self {
			case .addToFavorites:
				return "Add To Favorites"
			case .share:
				return "Share..."
			case .requestDesktopSite:
				return "Request Desktop Site"
			case .loadStartPage:
				return "Load Start Page"
			case .cancel:
				return "Cancel"
			case .addBookmark:
				return "Add Bookmark"
			case .addReadingList:
				return "Add ReadingList"
			case .closeTab:
				return "Close This Tab"
			case .closeAllTabs:
				return "Close All Tabs"
			case .newTab:
				return "New Tab"
			}
		}
		
		func makeAlertActions(_ handler: @escaping (UIAlertAction) -> (Void)) -> UIAlertAction {
			switch self {
			case .addToFavorites:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.default, handler: handler)
			case .share:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.default, handler: handler)
			case .requestDesktopSite:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.default, handler: handler)
			case .loadStartPage:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.default, handler: handler)
			case .cancel:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.cancel, handler: handler)
			case .addBookmark:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.default, handler: handler)
			case .addReadingList:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.default, handler: handler)
			case .closeTab:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.destructive, handler: handler)
			case .closeAllTabs:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.destructive, handler: handler)
			case .newTab:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.default, handler: handler)
			}
		}
		
	}
	
	func makeTabAlert(viewController: UIViewController,
							closeThisTabHandler: @escaping ((UIAlertAction) -> Void),
							closeAllTabsHandler: @escaping ((UIAlertAction) -> Void),
							newTabHandler: @escaping ((UIAlertAction) -> Void)) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
		
//		let closeThisTabAction = ActionType.closeTab.makeAlertActions { (action) -> (Void) in
//			print("close this tab action handler?")
//		}
		
		let closeThisTabAction = ActionType.closeTab.makeAlertActions(closeThisTabHandler)
		let closeAllTabsAction = ActionType.closeAllTabs.makeAlertActions(closeAllTabsHandler)
		let newTabAction = ActionType.newTab.makeAlertActions(newTabHandler)
		let cancelAction = ActionType.cancel.makeAlertActions { (action) -> (Void) in
			//cancels
		}

		alertController.addAction(closeThisTabAction)
		alertController.addAction(closeAllTabsAction)
		alertController.addAction(newTabAction)
		alertController.addAction(cancelAction)
		
		viewController.present(alertController, animated: true, completion: nil)
	}
	
	func makeBookmarkAlert(viewController: UIViewController, addBookmarkHandler: @escaping ((UIAlertAction) -> Void), addReadingListHandler: @escaping ((UIAlertAction) -> Void)) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
		
		let addBookmarkAction = ActionType.addBookmark.makeAlertActions(addBookmarkHandler)
		let addReadinglistAction = ActionType.addReadingList.makeAlertActions(addReadingListHandler)
		let cancelAction = ActionType.cancel.makeAlertActions { (action) -> (Void) in
			//cancel
		}
		
		alertController.addAction(addBookmarkAction)
		alertController.addAction(addReadinglistAction)
		alertController.addAction(cancelAction)
		
		viewController.present(alertController, animated: true, completion: nil)
	}
	
	
}

