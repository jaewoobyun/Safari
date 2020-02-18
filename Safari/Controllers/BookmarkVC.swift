//
//  BookmarkVC.swift
//  Safari
//
//  Created by 변재우 on 20200213//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit
import SwiftSoup

class BookmarkVC: UIViewController {
	
	// MARK: - Outlets
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var editButton: UIBarButtonItem!
	
	// MARK: - Constants X Properties
	var isDepthViewController:Bool = false
	var bookmarkData: [BookmarkData] = []
	
	let searchController = UISearchController(searchResultsController: nil)
	lazy var searchBar = UISearchBar(frame: CGRect.zero)
	var toggle: Bool = false
	var newFolderButton: UIBarButtonItem?
	var btnTemp: UIButton?
	
	var completionHandler: ((_ urlString: String?) -> ())?
	
	// MARK: - LifeCycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let library_path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
		print("library path is \(library_path)")
		
//		bookmarkData = [BookmarkData(titleString: "Favorites", child: [], indexPath: [0])]
		
		self.editButton = self.editButtonItem
		tableView.delegate = self
		tableView.dataSource = self
		tableView.tableHeaderView = searchController.searchBar
		tableView.isEditing = false
		toggle = tableView.isEditing
		tableView.allowsSelectionDuringEditing = true
		
		btnTemp = UIButton.init(type: UIButton.ButtonType.custom)
		btnTemp?.setTitle("New Folder", for: UIControl.State.normal)
		btnTemp?.setTitleColor(.systemBlue, for: UIControl.State.normal)
		btnTemp?.addTarget(self, action: #selector(addNewFolder), for: UIControl.Event.touchUpInside)
		btnTemp?.isHidden = true
		
		newFolderButton = UIBarButtonItem.init(customView: btnTemp!)
		
		self.toolbarItems?.insert(newFolderButton!, at: 0)
		let interaction = UIContextMenuInteraction(delegate: self)
		tableView.addInteraction(interaction)
		
		tableView.reloadData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.title = title
		
		UserDefaultsManager.shared.registerBookmarkDataObserver(vc: self, selector: #selector(updateBookmarkListData))
		
		if bookmarkData.count == 0, !isDepthViewController {
			self.title = "Bookmarks"
//			BookmarksDataModel.createSampleData()
//			let bookmarksArray = BookmarksDataModel.bookMarkDatas
//			bookmarkData = bookmarksArray
			
			
			bookmarkData = UserDefaultsManager.shared.loadUserBookMarkListData()
		}
		tableView.reloadData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		UserDefaultsManager.shared.removeBookmarkDataObserver()
	}

	@objc func updateBookmarkListData() {
		print("BookmarkVC updateBookmarkListData")
		if let navi = self.navigationController, navi.children.count > 1 {
			navi.popToRootViewController(animated: true)
		} else {
			self.bookmarkData.removeAll()
			self.bookmarkData = UserDefaultsManager.shared.loadUserBookMarkListData()
			tableView.reloadData()
		}
	}
	
	@IBAction func editButton(_ sender: UIBarButtonItem) {
		toggle = !toggle
		if toggle == true {
			tableView.isEditing = true
			btnTemp?.isHidden = false
			sender.title = "Done"
		} else {
			tableView.isEditing = false
			btnTemp?.isHidden = true
			sender.title = "Edit"
		}
	}
	
	@objc func addNewFolder() {
		print("Add new folder!")
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let editFolderVC = storyboard.instantiateViewController(identifier: "EditFolderVC")
		if let editFolder = editFolderVC as? EditFolderVC {
			editFolder.caseType = .AddNewFolder
			self.navigationController?.pushViewController(editFolder, animated: true)
		}
	}
	
	
	
	
}

// MARK: - UISearchResultsUpdating
extension BookmarkVC: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		//
	}
}

// MARK: - UITableView Delegate, Datasource
extension BookmarkVC: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return bookmarkData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "sample", for: indexPath)
		
		if !bookmarkData[indexPath.row].isFolder {
			cell.imageView?.image = UIImage(systemName: "book")
			cell.textLabel?.text = bookmarkData[indexPath.row].titleString
			cell.editingAccessoryType = .disclosureIndicator
			return cell
		}
//		else if bookmarkData[0].titleString == "Favorites" && bookmarkData[indexPath.row].isFolder {
//			cell.imageView?.image = UIImage(systemName: "star")
//		}
		else {
			cell.imageView?.image = UIImage(systemName: "folder")
		}
		
		cell.textLabel?.text = bookmarkData[indexPath.row].titleString
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("didSelectRowAt \(indexPath)")
		let storybaord = UIStoryboard(name: "Main", bundle: Bundle.main)
		if let reusableVC = storybaord.instantiateViewController(identifier: "BookmarkVC") as? BookmarkVC {
			if bookmarkData[indexPath.row].isFolder {
				if tableView.isEditing {
					print("is Folder and editing")
					if let reusableEditFolder = storyboard?.instantiateViewController(identifier: "EditFolderVC") as? EditFolderVC {
						reusableEditFolder.selectedIndexPath = indexPath
						navigationController?.pushViewController(reusableEditFolder, animated: true)
					}
				}
				else {
					print("is Folder and not editing")
					reusableVC.navigationController?.title = bookmarkData[indexPath.row].titleString
					reusableVC.title = bookmarkData[indexPath.row].titleString
					reusableVC.bookmarkData = bookmarkData[indexPath.row].child
					reusableVC.isDepthViewController = true
					
					if let cc = self.completionHandler {
						reusableVC.completionHandler = cc
					}
					navigationController?.pushViewController(reusableVC, animated: true)
				}
			}
			else {
				print("is bookmark and not editing")
				guard let urlString = bookmarkData[indexPath.row].urlString else { return }
				guard let titleString = bookmarkData[indexPath.row].titleString else { return }
				if tableView.isEditing {
					print("is bookmark and editing")
					if let reusableEditBookmarkVC = storyboard?.instantiateViewController(identifier: "EditBookmarkVC") as? EditBookmarkVC {
						reusableEditBookmarkVC.bookmarkTitle = titleString
						reusableEditBookmarkVC.address = urlString
						navigationController?.pushViewController(reusableEditBookmarkVC, animated: true)
					}
				}
				else {
					NotificationGroup.shared.post(type: .bookmarkURLName, userInfo: ["selectedBookmarkURL": urlString])
					self.dismiss(animated: true, completion: nil)
				}
			}
		} else {
			print("vc load fail")
		}
	}
	
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .delete
	}
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		let data = bookmarkData[indexPath.row]
		let removeTitle = data.titleString ?? ""
		
		if editingStyle == .delete {
			bookmarkData.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				UserDefaultsManager.shared.removeBookmarkFolderItem(at: removeTitle)
			}
		}
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		//
	}
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
		guard let bookmarkVC = storyboard?.instantiateViewController(identifier: "BookmarkVC") as? BookmarkVC else {
			preconditionFailure("Failed to preview bookmarkVC")
		}
		
		// MARK: Actions
		let editFolderAction = Menus.MenuActions.edit.createButtonAction { (action) in
			let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
			if let reusableEditFolder = storyboard.instantiateViewController(identifier: "EditFolderVC") as? EditFolderVC {
				reusableEditFolder.folderTitle = self.bookmarkData[indexPath.item].titleString
				//TODO: - need to pass the location of the editing folder to EditFolderVC
				reusableEditFolder.selectedIndexPath = indexPath
				self.navigationController?.pushViewController(reusableEditFolder, animated: true)
			}
		}
		
		let editBookmarkAction = Menus.MenuActions.edit.createButtonAction { (action) in
			let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
			guard let urlString = self.bookmarkData[indexPath.row].urlString else { return }
			guard let titleString = self.bookmarkData[indexPath.row].titleString else { return }
			if let reusableEditBookmarkVC = storyboard.instantiateViewController(identifier: "EditBookmarkVC") as? EditBookmarkVC {
				reusableEditBookmarkVC.bookmarkTitle = titleString
				reusableEditBookmarkVC.address = urlString
				self.navigationController?.pushViewController(reusableEditBookmarkVC, animated: true)
			}
		}
		
		let deleteAction = Menus.MenuActions.delete.createDeleteConfirmationMenu { (action) in
			print("deleted!!")
			let data = self.bookmarkData[indexPath.row]
			let removeTitle = data.titleString ?? ""
			self.bookmarkData.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				UserDefaultsManager.shared.removeBookmarkFolderItem(at: removeTitle)
			}
		}
		
		let copyAction = Menus.MenuActions.copy.createButtonAction { (action) in
			print("Copy!!")
			if let bookmarkUrlString = self.bookmarkData[indexPath.row].urlString {
				UIPasteboard.general.string = bookmarkUrlString
			}
		}
		let copyContentsAction = Menus.MenuActions.copyContents.createButtonAction { (action) in
			print("Copy Contents!")
			for item in self.bookmarkData[indexPath.row].child {
				if let urlStrings = item.urlString {
					UIPasteboard.general.strings?.append(urlStrings)
				}
			}
		}
		let openInNewTabAction = Menus.MenuActions.openInNewTab.createButtonAction { (action) in
			print("Open in New Tab!")
		}
		let openInNewTabsAction = Menus.MenuActions.openInNewTabs.createButtonAction { (action) in
			print("Open in New Tabs!")
		}
		
		///폴더일때
		if bookmarkData[indexPath.row].isFolder {
			print("isFolder not empty")
			bookmarkVC.navigationController?.title = bookmarkData[indexPath.row].titleString
			bookmarkVC.title = bookmarkData[indexPath.row].titleString
			bookmarkVC.bookmarkData = bookmarkData[indexPath.row].child
			bookmarkVC.isDepthViewController = true
			
			///빈 폴더일때
			if bookmarkData[indexPath.row].child.isEmpty {
				print("isFolder and empty Leaf Node")
				return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (actions) -> UIMenu? in
					return UIMenu(title: "Menu", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [
						editFolderAction, deleteAction
					])
				}
				
			}
			///들어있는 폴더일때
			return UIContextMenuConfiguration(identifier: nil, previewProvider: {return bookmarkVC}) { (menuElements) -> UIMenu? in
				return UIMenu(title: "Menu", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [
					copyContentsAction, openInNewTabsAction, editFolderAction, deleteAction
				])
			}
			
		}
		else { ///북마크 일때.
			print("is Bookmark")
			//TODO: show a preview of the link (webView)
			return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (actions) -> UIMenu? in
				return UIMenu(title: "Menu", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [
					copyAction, openInNewTabAction, editBookmarkAction, deleteAction
				])
			}
		}
		
	
	}
	
	func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		animator.addCompletion {
			//TODO: ???
		}
	}
	
	
}

// MARK: UI ContextMenuInteractionDelegate
extension BookmarkVC: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else { return nil }
		guard let bookmarkVC = storyboard?.instantiateViewController(identifier: "BookmarkVC") as? BookmarkVC else {
			preconditionFailure("Failed to preview bookmarkVC")
		}
		// MARK: Actions
		let editFolderAction = Menus.MenuActions.edit.createButtonAction { (action) in
			let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
			if let reusableEditFolder = storyboard.instantiateViewController(identifier: "EditFolderVC") as? EditFolderVC {
				reusableEditFolder.folderTitle = self.bookmarkData[indexPath.item].titleString
				//TODO: - need to pass the location of the editing folder to EditFolderVC
				reusableEditFolder.selectedIndexPath = indexPath
				self.navigationController?.pushViewController(reusableEditFolder, animated: true)
			}
		}
		
		let editBookmarkAction = Menus.MenuActions.edit.createButtonAction { (action) in
			let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
			guard let urlString = self.bookmarkData[indexPath.row].urlString else { return }
			guard let titleString = self.bookmarkData[indexPath.row].titleString else { return }
			if let reusableEditBookmarkVC = storyboard.instantiateViewController(identifier: "EditBookmarkVC") as? EditBookmarkVC {
				reusableEditBookmarkVC.bookmarkTitle = titleString
				reusableEditBookmarkVC.address = urlString
				self.navigationController?.pushViewController(reusableEditBookmarkVC, animated: true)
			}
		}
		
		let deleteAction = Menus.MenuActions.delete.createDeleteConfirmationMenu { (action) in
			print("deleted!!")
			let data = self.bookmarkData[indexPath.row]
			let removeTitle = data.titleString ?? ""
			self.bookmarkData.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				UserDefaultsManager.shared.removeBookmarkFolderItem(at: removeTitle)
			}
		}
		
		let copyAction = Menus.MenuActions.copy.createButtonAction { (action) in
			print("Copy!!")
			if let bookmarkUrlString = self.bookmarkData[indexPath.row].urlString {
				UIPasteboard.general.string = bookmarkUrlString
			}
		}
		let copyContentsAction = Menus.MenuActions.copyContents.createButtonAction { (action) in
			print("Copy Contents!")
			for item in self.bookmarkData[indexPath.row].child {
				if let urlStrings = item.urlString {
					UIPasteboard.general.strings?.append(urlStrings)
				}
			}
		}
		let openInNewTabAction = Menus.MenuActions.openInNewTab.createButtonAction { (action) in
			print("Open in New Tab!")
		}
		let openInNewTabsAction = Menus.MenuActions.openInNewTabs.createButtonAction { (action) in
			print("Open in New Tabs!")
		}
		
		///폴더일때
		if bookmarkData[indexPath.row].isFolder {
			print("isFolder not empty")
			bookmarkVC.navigationController?.title = bookmarkData[indexPath.row].titleString
			bookmarkVC.title = bookmarkData[indexPath.row].titleString
			bookmarkVC.bookmarkData = bookmarkData[indexPath.row].child
			bookmarkVC.isDepthViewController = true
			
			///빈 폴더일때
			if bookmarkData[indexPath.row].child.isEmpty {
				print("isFolder and empty Leaf Node")
				return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (actions) -> UIMenu? in
					return UIMenu(title: "Menu", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [
						editFolderAction, deleteAction
					])
				}
				
			}
			///들어있는 폴더일때
			return UIContextMenuConfiguration(identifier: nil, previewProvider: {return bookmarkVC}) { (menuElements) -> UIMenu? in
				return UIMenu(title: "Menu", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [
					copyContentsAction, openInNewTabsAction, editFolderAction, deleteAction
				])
			}
			
		}
		else { ///북마크 일때.
			print("is Bookmark")
			//TODO: show a preview of the link (webView)
			return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (actions) -> UIMenu? in
				return UIMenu(title: "Menu", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [
					copyAction, openInNewTabAction, editBookmarkAction, deleteAction
				])
			}
		}
	
	}
	
	
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		animator.addCompletion {
			if let vc = animator.previewViewController {
				self.show(vc, sender: self)
			}
		}
	}
	
	
	
}
