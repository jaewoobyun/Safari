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
		///Nav Functionalities
		case addToFavorites
		case share
		case requestDesktopSite
		case loadStartPage
		
		///common
		case cancel
		
		/// Bookmark Button LongPress
		case addBookmark
		case addReadingList
		
		/// Tabs Button LongPress
		case closeTab
		case closeAllTabs
		case newTab
		
		/// History Clearing
		case lastHour
		case today
		case todayAndYesterday
		case allTime
		
		
		func getTitle() -> String {
			switch self {
			case .addToFavorites:
				return "Add To Favorites(Bookmark)"
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
			case .lastHour:
				return "The Last Hour"
			case .today:
				return "Today"
			case .todayAndYesterday:
				return "Today and Yesterday"
			case .allTime:
				return "All Time"
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
			case .lastHour:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.destructive, handler: handler)
			case .today:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.destructive, handler: handler)
			case .todayAndYesterday:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.destructive, handler: handler)
			case .allTime:
				return UIAlertAction(title: self.getTitle(), style: UIAlertAction.Style.destructive, handler: handler)
				
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
	
	func makeClearHistoryAlert(viewController: UIViewController, lastHourHandler: @escaping ((UIAlertAction) -> Void), todayHandler: @escaping ((UIAlertAction) -> Void), todayAndYesterdayHandler: @escaping ((UIAlertAction) -> Void), allTimeHandler: @escaping ((UIAlertAction) -> Void) ) {
		let alertController = UIAlertController(title: nil, message: "Clearing will remove history, cookies, and other browsing data. History will be cleared from devices signed into your iCloud Account. Clear from:", preferredStyle: UIAlertController.Style.actionSheet)
		
		let lastHourAction = ActionType.lastHour.makeAlertActions(lastHourHandler)
		let todayAction = ActionType.today.makeAlertActions(todayHandler)
		let todayAndYesterdayAction = ActionType.todayAndYesterday.makeAlertActions(todayAndYesterdayHandler)
		let allTimeAction = ActionType.allTime.makeAlertActions(allTimeHandler)
		let cancelAction = ActionType.cancel.makeAlertActions { (action) -> (Void) in
			//cancel
		}
		
		alertController.addAction(lastHourAction)
		alertController.addAction(todayAction)
		alertController.addAction(todayAndYesterdayAction)
		alertController.addAction(allTimeAction)
		alertController.addAction(cancelAction)
		
		viewController.present(alertController, animated: true, completion: nil)
		
	}
	
	
}

