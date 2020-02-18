//
//  ReadingListVC.swift
//  Safari
//
//  Created by 변재우 on 20200212//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class ReadingListVC: UIViewController {
	
	//MARK: - Outlets
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var editButton: UIBarButtonItem!
	@IBOutlet weak var secretButton: UIBarButtonItem!
	@IBOutlet weak var instructionLabel: UILabel!
	
	var toggle: Bool = false
	var isContentsHidden: Bool = true
	
	enum AuthenticationState {
		case loggedin, loggedout
	}
	
	var state = AuthenticationState.loggedout {
		didSet {
			secretButton.image = state == .loggedin ? UIImage(systemName: "lock.open") : UIImage(systemName: "lock")
			tableView.isHidden = state == .loggedin ? false : true
		}
	}
	
	let searchController = UISearchController(searchResultsController: nil)
	lazy var searchBar = UISearchBar(frame: CGRect.zero)
	
	var readingListDatas : [ReadingListData] = []
	
	var deleteButton: UIButton?
	var deleteBarButton: UIBarButtonItem?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Reading List"
		self.navigationController?.navigationBar.isHidden = false
		
		//		if isContentsHidden == true {
		//			self.tableView.isHidden = true
		//		}
		//		if isContentsHidden == false {
		//			self.tableView.isHidden = false
		//		}
		state = .loggedout
		
		self.editButton = self.editButtonItem
		tableView.delegate = self
		tableView.dataSource = self
		tableView.tableHeaderView = searchController.searchBar
		tableView.isEditing = false
		toggle = tableView.isEditing
		
		tableView.register(UINib(nibName: "ReadingListCell", bundle: nil), forCellReuseIdentifier: "ReadingListCell")
		tableView.allowsMultipleSelectionDuringEditing = true
		
		deleteButton = UIButton.init(type: UIButton.ButtonType.system)
		deleteButton?.setTitle("delete", for: UIControl.State.normal)
		deleteBarButton = UIBarButtonItem.init(customView: deleteButton!)
		deleteButton?.addTarget(self, action: #selector(deleteSelection), for: UIControl.Event.touchUpInside)
		deleteButton?.isHidden = true
		
		self.toolbarItems?.insert(deleteBarButton!, at: 2)
		
		tableView.reloadData()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		//		if isContentsHidden {
		//			self.tableView.isHidden = true
		//		} else {
		//			self.tableView.isHidden = false
		//		}
		UserDefaultsManager.shared.registerReadingListDataObserver(vc: self, selector: #selector(updateReadingListDatas))
		UserDefaultsManager.shared.loadUserReadingListData()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		UserDefaultsManager.shared.removeReadingListDataObserver()
	}
	
	@objc func updateReadingListDatas() {
		print("readinglistVC updateReadinglistDatas")
		self.readingListDatas.removeAll()
		readingListDatas = UserDefaultsManager.shared.readingListDataSave
		
		tableView.reloadData()
	}
	
	@IBAction func bioAuthenticate(_ sender: UIBarButtonItem) {
		//		if isContentsHidden == true {
		//			sender.image = UIImage(systemName: "lock")
		//			self.tableView.isHidden = true
		//			isContentsHidden = false
		////			authenticationWithTouchID()
		//		}
		//		if isContentsHidden == false {
		//			sender.image = UIImage(systemName: "lock.open")
		//			self.tableView.isHidden = false
		//			isContentsHidden = true
		//		}
		
		//		self.isContentsHidden = !self.isContentsHidden
		//		authenticationWithTouchID()
		
		
		//		if state == .loggedout {
		//			state = .loggedin
		//		}
		//		if state == .loggedin {
		//			state = .loggedout
		//		} else {
		////			authenticationWithTouchID()
		//		}
		
		switch state {
		case .loggedin:
			state = .loggedout
		case .loggedout:
			//			state = .loggedin
			authenticationWithTouchID()
		}
		
	}
	
	@IBAction func editButtonAction(_ sender: UIBarButtonItem) {
		print("Edit!")
		toggle = !toggle
		if toggle == true {
			sender.title = "Done"
			tableView.isEditing = true
			//			tableView.allowsMultipleSelectionDuringEditing = true
			//			UserDefaultsManager.shared.removeReadingListDataObserver()
			
			deleteButton?.isHidden = false
			
		} else {
			tableView.isEditing = false
			deleteButton?.isHidden = true
			sender.title = "Edit"
		}
	}
	
	
	@objc func deleteSelection() {
		print("deletebutton pressed!!")
		if let selectedRows = tableView.indexPathsForSelectedRows {
			//1
			//			var items = [String]()
			var uuids: [String] = []
			
			//지우고싶은, 선택된 아이템을 걸러낸다.
			for indexPath in selectedRows {
				uuids.append(readingListDatas[indexPath.row].uuid)
			}
			
			//3
			/// 이 vc 에서 쓰는 데이터도 지워야 하기 때문에 readingListData 도 필터해 지운다.
			self.readingListDatas = self.readingListDatas.filter({ (data) -> Bool in
				for removeItem in uuids {
					if removeItem == data.uuid {
						return false
					}
				}
				
				return true
			})
			
			tableView.beginUpdates()
			tableView.deleteRows(at: selectedRows, with: UITableView.RowAnimation.automatic)
			tableView.endUpdates()
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				UserDefaultsManager.shared.removeReadingListItemWithUUID(uuids: uuids)
			}
			
		}
		
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destination.
	// Pass the selected object to the new view controller.
	}
	*/
	
}

extension ReadingListVC: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		print("updateSearchResults")
	}
	
}

extension ReadingListVC : UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return readingListDatas.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		//		let cell = tableView.dequeueReusableCell(withIdentifier: "readinglistprototype", for: indexPath)
		let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingListCell", for: indexPath) as! ReadingListCell
		let data = readingListDatas[indexPath.row]
		cell.setCellData(data)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("didSelectRowAt \(indexPath)")
		let urlString = self.readingListDatas[indexPath.row].urlString
		
		if tableView.isEditing == true {
			print("tableview is editing")
			
		}
		else {
			NotificationGroup.shared.post(type: .readinglistURLName, userInfo: ["selectedReadinglistURL": urlString])
			self.dismiss(animated: true, completion: nil)
		}
		
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .delete
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				UserDefaultsManager.shared.removeReadingListItemAtIndexPath(indexPath: indexPath)
			}
		}
		
	}
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (actions) -> UIMenu? in
			
			let deleteCancel = Menus.MenuActions.cancel.createButtonAction({ (action) in
				print("cancel")
			})
			let deleteConfirmation = Menus.MenuActions.delete.createButtonAction({ (action) in
				//				self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					UserDefaultsManager.shared.removeReadingListItemAtIndexPath(indexPath: indexPath)
				}
				self.tableView.reloadData()
			})
			let deleteAction = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [deleteCancel, deleteConfirmation])
			
			return UIMenu(title: "Menu", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [
				Menus.MenuActions.copy.createButtonAction({ (action) in
					print("Copying", self.readingListDatas[indexPath.row].urlString!)
					if let urlString = self.readingListDatas[indexPath.row].urlString {
						UIPasteboard.general.string = urlString
						
					}
				}),
				Menus.MenuActions.openInNewTab.createButtonAction({ (action) in
					//TODO: - need to implement this
					print("open in New Tabs!", action)
				}),
				deleteAction
			])
		}
	}
	
	func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		//
	}
	
	
	//	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
	//		let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "delete") { (action, indexPath) in
	//			// delete
	//		}
	//
	//		let saveOfflineAction = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: "Save Offline") { (action, indexPath) in
	//			// save offline
	//		}
	//
	//
	//		return [deleteAction, saveOfflineAction]
	//	}
	
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		// leading swipe
		let markUnreadAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Mark Unread") { (ac: UIContextualAction, view: UIView, success: @escaping (Bool) -> Void) in
			// Call mark unread Action
			
			//Reset state
			success(true)
		}
		markUnreadAction.backgroundColor = UIColor.systemBlue
		
		return UISwipeActionsConfiguration(actions: [markUnreadAction])
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Delete") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
			// Call edit action
			UserDefaultsManager.shared.removeReadingListItemAtIndexPath(indexPath: indexPath)
			//Reset state
			
			success(true)
		}
		
		let saveOfflineAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Save Offline") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
			// Call edit aciton
			
			// Reset state
			
			success(true)
		}
		
		return UISwipeActionsConfiguration(actions: [deleteAction, saveOfflineAction])
		
	}
	
	
}


extension ReadingListVC {
	
	func authenticationWithTouchID() {
		
		
		let localAuthenticationContext = LAContext()
		//		 localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
		
		var authError: NSError?
		let reasonString = "To access the secure data"
		
		
		//생체인증을 사용가능한가?
		if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
			
			localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonString) { success, evaluateError in
				
				if success {
					//TODO: User authenticated successfully, take appropriate action
					//						self.isContentsHidden = false
					DispatchQueue.main.async { [weak self] in
						self?.state = .loggedin
					}
					
				} else {
					//TODO: User did not authenticate successfully, look at error and take appropriate action
					guard let error = evaluateError else {
						return
					}
					
					print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
				}
			}
		} else {
			
			if let error = authError {
				print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
			} else {
				print("unknow error")
			}
			
		}
	}
	
	
	func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
		var message = ""
		if #available(iOS 11.0, macOS 10.13, *) {
			switch errorCode {
			case LAError.biometryNotAvailable.rawValue:
				message = "Authentication could not start because the device does not support biometric authentication."
				
			case LAError.biometryLockout.rawValue:
				message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
				
			case LAError.biometryNotEnrolled.rawValue:
				message = "Authentication could not start because the user has not enrolled in biometric authentication."
				
			default:
				message = "Did not find error code on LAError object"
			}
		} else {
			switch errorCode {
			case LAError.touchIDLockout.rawValue:
				message = "Too many failed attempts."
				
			case LAError.touchIDNotAvailable.rawValue:
				message = "TouchID is not available on the device"
					
			case LAError.touchIDNotEnrolled.rawValue:
				message = "TouchID is not enrolled on the device"
				
			default:
				message = "Did not find error code on LAError object"
			}
		}
		
		return message;
	}
	
	func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
		
		var message = ""
		
		switch errorCode {
			
		case LAError.authenticationFailed.rawValue:
			message = "The user failed to provide valid credentials"
			
		case LAError.appCancel.rawValue:
			message = "Authentication was cancelled by application"
			
		case LAError.invalidContext.rawValue:
			message = "The context is invalid"
			
		case LAError.notInteractive.rawValue:
			message = "Not interactive"
			
		case LAError.passcodeNotSet.rawValue:
			message = "Passcode is not set on the device"
			
		case LAError.systemCancel.rawValue:
			message = "Authentication was cancelled by the system"
			
		case LAError.userCancel.rawValue:
			message = "The user did cancel"
			
		case LAError.userFallback.rawValue:
			message = "The user chose to use the fallback"
			
		default:
			message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
		}
		
		return message
	}
}

