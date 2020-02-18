//
//  Menus.swift
//  Safari
//
//  Created by 변재우 on 20200207//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit

class Menus {
	static let shared = Menus()
	
	var delegate: Menus?
	
	public enum MenuActions {
		///Copy
		case copy
		///Copy Contents
		case copyContents
		///Open In New Tab
		case openInNewTab
		///Open In New Tabs
		case openInNewTabs
		/// Edit
		case edit
		/// Delete cancel
		case cancel
		/// DeleteConfirmation
		case delete
		
		func getTitle() -> String {
			switch self {
			case .copy: return "Copy"
			case .copyContents: return "Copy Contents"
			case .openInNewTab: return "Open in New Tab"
			case .openInNewTabs: return "Open in New Tabs"
			case .edit: return "Edit"
			case .cancel: return "Cancel"
			case .delete: return "Delete"
			}
		}
		
		func createButtonAction(_ baseHandle: @escaping UIActionHandler) -> UIAction {
			switch self {
			case .copy:
				return UIAction(title: self.getTitle(), image: UIImage(systemName: "doc.on.doc"), identifier: nil, discoverabilityTitle: nil, state: UIMenuElement.State.off, handler: baseHandle)
			case .copyContents:
				return UIAction(title: self.getTitle(), image: UIImage(systemName: "doc.on.doc"), identifier: nil, discoverabilityTitle: nil, state: UIMenuElement.State.off, handler: baseHandle)
			case .openInNewTab:
				return UIAction(title: self.getTitle(), image: UIImage(systemName: "plus.rectangle.on.rectangle"), identifier: nil, discoverabilityTitle: nil, attributes: UIMenuElement.Attributes.init(), state: UIMenuElement.State.off, handler: baseHandle)
			case .openInNewTabs:
				return UIAction(title: self.getTitle(), image: UIImage(systemName: "plus.rectangle.on.rectangle"), identifier: nil, discoverabilityTitle: nil, attributes: UIMenuElement.Attributes.init(), state: UIMenuElement.State.off, handler: baseHandle)
			case .edit:
				return UIAction(title: self.getTitle(), image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, attributes: UIMenuElement.Attributes.init(), state: UIMenuElement.State.off, handler: baseHandle)
			case .cancel:
				return UIAction(title: self.getTitle(), image: UIImage(systemName: "xmark"), handler: baseHandle)
			case .delete:
				return UIAction(title: self.getTitle(), image: UIImage(systemName: "checkmark"), identifier: nil, discoverabilityTitle: nil, attributes: UIMenuElement.Attributes.destructive, state: UIMenuElement.State.off, handler: baseHandle)
			}
		}
		
		func createDeleteConfirmationMenu(_baseHandle: @escaping UIActionHandler) -> UIMenu {
			return UIMenu(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, options: UIMenu.Options.destructive, children: [
				MenuActions.cancel.createButtonAction(_baseHandle),
				MenuActions.delete.createButtonAction(_baseHandle)
			])
		}
	}
	
	enum MenuStyle {
		case emptyFolder
		case folder
		case bookmark
		case readingList
		case history
		
//		func createMenu(_ baseHandle:@escaping UIActionHandler) -> UIMenu {
//			return UIMenu(title: "Menu", image: nil, identifier: nil, options: UIMenu.Options.init(), children: self.getMenuButtons(baseHandle))
//		}

		func getMenuButtons(_ baseHandle:@escaping UIActionHandler) -> [UIAction] {
			switch self {
			case .emptyFolder:
				return [
					MenuActions.edit.createButtonAction(baseHandle),
					MenuActions.delete.createButtonAction(baseHandle)

				]
			case .folder:
				return [
					MenuActions.copyContents.createButtonAction(baseHandle),
					MenuActions.openInNewTabs.createButtonAction(baseHandle),
					MenuActions.edit.createButtonAction(baseHandle),
					MenuActions.delete.createButtonAction(baseHandle)
				]
			case .bookmark:
				return [
					MenuActions.copy.createButtonAction(baseHandle),
					MenuActions.openInNewTab.createButtonAction(baseHandle),
					MenuActions.edit.createButtonAction(baseHandle),
					MenuActions.delete.createButtonAction(baseHandle)
				]
			case .readingList:
				return [
					MenuActions.copy.createButtonAction(baseHandle),
					MenuActions.openInNewTab.createButtonAction(baseHandle),
					MenuActions.delete.createButtonAction(baseHandle)
				]
			case .history:
				return [
					MenuActions.copy.createButtonAction(baseHandle),
					MenuActions.openInNewTab.createButtonAction(baseHandle),
					MenuActions.delete.createButtonAction(baseHandle)
				]
			}
		}
		
//		func makeMenu(menuStyle: MenuStyle, editHandler: @escaping UIActionHandler, deleteHandler: @escaping UIActionHandler) -> UIMenu {
//
//			let edit = MenuActions.edit.createButtonAction(editHandler)
//			let delete = MenuActions.delete.createButtonAction(deleteHandler)
//
//			return UIMenu(title: "", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [edit, delete])
//		}
		
		
		
	}
	
//	func makeContextMenu(menuStyle: MenuStyle, previewProvider: UIViewController, handler: @escaping UIActionHandler) -> UIMenu {
//
//
//	}
	
//	func makeMenu(menuStyle: MenuStyle, handler: @escaping UIActionHandler, prevVC: UIViewController) -> UIMenu {
////		let menu = UIMenu(title: "", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [])
//		
//		switch menuStyle {
//		case .emptyFolder:
//			let menu = UIMenu(title: "", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [menuStyle.getMenuButtons(handler)])
//		case .folder:
//
//		case .bookmark:
//
//		case .readingList:
//
//		case .history:
//
//		}
//		
//		return menu/
//	}
	
//	func makeMenu(menuStyle: MenuStyle, prevVC: UIViewController) {
//		let menu = menuStyle.createMenu { (action) in
//			print("action.title : \(action.title)")
//		}
//
//		UIContextMenuConfiguration(identifier: nil, previewProvider: {return prevVC}) { (actions) -> UIMenu? in
//			return menu
//		}
//	}
	
	
	
}
