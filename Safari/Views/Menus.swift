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
	
	public enum MenuType {
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
		case deleteCancel
		/// DeleteConfirmation
		case deleteConfirmation
		
		func createButtonAction(_ baseHandle: @escaping UIActionHandler) -> UIAction {
			switch self {
			case .copy:
				return UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc"), identifier: nil, discoverabilityTitle: nil, state: UIMenuElement.State.off, handler: baseHandle)
			case .copyContents:
				return UIAction(title: "Copy Contents", image: UIImage(systemName: "doc.on.doc"), identifier: nil, discoverabilityTitle: nil, state: UIMenuElement.State.off, handler: baseHandle)
			case .openInNewTab:
				return UIAction(title: "Open in New Tab", image: UIImage(systemName: "plus.rectangle.on.rectangle"), identifier: nil, discoverabilityTitle: nil, attributes: UIMenuElement.Attributes.init(), state: UIMenuElement.State.off, handler: baseHandle)
			case .openInNewTabs:
				return UIAction(title: "Open in New Tabs", image: UIImage(systemName: "plus.rectangle.on.rectangle"), identifier: nil, discoverabilityTitle: nil, attributes: UIMenuElement.Attributes.init(), state: UIMenuElement.State.off, handler: baseHandle)
			case .edit:
				return UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, attributes: UIMenuElement.Attributes.init(), state: UIMenuElement.State.off, handler: baseHandle)
			case .deleteCancel:
				return UIAction(title: "Cancel", image: UIImage(systemName: "xmark"), handler: baseHandle)
			case .deleteConfirmation:
				return UIAction(title: "Delete", image: UIImage(systemName: "checkmark"), identifier: nil, discoverabilityTitle: nil, attributes: UIMenuElement.Attributes.destructive, state: UIMenuElement.State.off, handler: baseHandle)
			}
		}
		
		func createDeleteConfirmationMenu(_baseHandle: @escaping UIActionHandler) -> UIMenu {
			return UIMenu(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, options: UIMenu.Options.destructive, children: [
				MenuType.deleteCancel.createButtonAction(_baseHandle),
				MenuType.deleteConfirmation.createButtonAction(_baseHandle)
			
			])
		}
	}
	
	enum MenuStyle {
		case emptyFolder
		case folder
		case bookmark
//		case readingList
//		case history
		
		func createMenu(_ baseHandle:@escaping UIActionHandler) -> UIMenu {
			return UIMenu(title: "Menu", image: nil, identifier: nil, options: UIMenu.Options.init(), children: self.getMenuButtons(baseHandle))
		}

		func getMenuButtons(_ baseHandle:@escaping UIActionHandler) -> [UIAction] {
			switch self {
			case .emptyFolder:
				return [
					MenuType.edit.createButtonAction(baseHandle),
					MenuType.deleteConfirmation.createButtonAction(baseHandle)
					
				]
			case .folder:
				return [
					MenuType.copyContents.createButtonAction(baseHandle),
					MenuType.openInNewTabs.createButtonAction(baseHandle),
					MenuType.edit.createButtonAction(baseHandle),
					MenuType.deleteConfirmation.createButtonAction(baseHandle)
				]
			case .bookmark:
				return [
					MenuType.copy.createButtonAction(baseHandle),
					MenuType.openInNewTab.createButtonAction(baseHandle),
					MenuType.edit.createButtonAction(baseHandle),
					MenuType.deleteConfirmation.createButtonAction(baseHandle)
				]
			}
		}
		
	}
	
	func makeMenu(menuStyle: MenuStyle, prevVC: UIViewController) {
		let menu = menuStyle.createMenu { (action) in
			print("action.title : \(action.title)")
		}
		
		UIContextMenuConfiguration(identifier: nil, previewProvider: {return prevVC}) { (actions) -> UIMenu? in
			return menu
		}
	}
	
	
	
}
