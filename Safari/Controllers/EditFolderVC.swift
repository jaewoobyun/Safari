//
//  EditFolderVC.swift
//  Safari
//
//  Created by 변재우 on 20200217//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit
import CITreeView

class EditFolderVC: UIViewController {
	
	// MARK: - Outlets
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var treeView: CITreeView!
	
	enum CaseType {
		case AddNewFolder
		case EditFolder
		
		func getTitle() -> String {
			switch self {
			case .AddNewFolder: return "Add New Folder"
			case .EditFolder: return "Edit Folder"
			}
		}
		
		func getButtonTitle() -> UIBarButtonItem.SystemItem {
			switch self {
			case .AddNewFolder: return .add
			case .EditFolder: return .save
			}
		}
		
		
	}
	
	var isExpanded: Bool = true
	var caseType: CaseType = .EditFolder
	var folderTitle: String?
	var bookmarkData: NSMutableArray = []
	var folderTitleInputText: String?
	var selectedNode: CITreeViewNode? //
	var selectedIndexPath: IndexPath? //
	
	///선택된 노드의(select) 부모를 조회하여, 선택 줄이 몇 레벨에 있는지 화인한다.
	/// [0,0,1] -> let now = bookmarkData[0].child[0].child[0],  === > now.child.append(folder)
	var selectNodeIndexs:[Int] = []
	
	
	var editTargetData: BookmarkData? = nil
	
	//MARK: - Life Cycle
	override func viewDidLoad() {
		self.title = caseType.getTitle()
		
		super.viewDidLoad()
		self.bookmarkData.addObjects(from: UserDefaultsManager.shared.loadUserBookMarkListData())
		
//		if let folderTitle = folderTitle {
//			let editTargetData = locateSelectedFolder(targetArray: (self.bookmarkData as! [BookmarkData]), searchKeyword: folderTitle)
//			editTargetData?.titleString = self.titleTextField.text
//			self.editTargetData = editTargetData
//		}
		
//		if let editTargetData = self.editTargetData {
//			//뷰 사용가능
//			print(editTargetData)
//
//
//		} else {
//			if let navi = self.navigationController {
//				navi.popViewController(animated: true)
//			}
//		}
		
		//self.bookmarkData = UserDefaultsManager.shared.loadUserBookMarkListData()
		
		titleTextField.text = folderTitle
		
		titleTextField.delegate = self
		
		treeView.allowsMultipleSelection = false
		treeView.treeViewDelegate = self
		treeView.treeViewDataSource = self
		
		treeView.collapseNoneSelectedRows = false //
		treeView.register(UINib(nibName: "FolderCell", bundle: nil), forCellReuseIdentifier: "folderCell")
		treeView.reloadData()
		treeView.expandAllRows()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: caseType.getButtonTitle(), target: self, action: #selector(saveFolder))
		
	}

	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.title = super.title
		checkTitleIsntEmpty()
		
		if caseType == .EditFolder {
			if let folderTitle = folderTitle {
				let editTargetData = locateSelectedFolder(targetArray: (self.bookmarkData as! [BookmarkData]), searchKeyword: folderTitle)
	//			editTargetData?.titleString = self.titleTextField.text
				self.editTargetData = editTargetData
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	@IBAction func expandCollapseButton(_ sender: UIButton) {
		isExpanded = !isExpanded
		if isExpanded {
			sender.setTitle("Expand All", for: UIControl.State.normal)
			self.treeView.collapseAllRows()
		}
		else {
			sender.setTitle("Collapse All", for: UIControl.State.normal)
			self.treeView.expandAllRows()
		}
		
	}
	
	
	func checkTitleIsntEmpty() {
		//TODO: - Not sure if this is used;
		if let titleText = self.titleTextField.text, !titleText.isEmpty {
			self.navigationItem.rightBarButtonItem?.isEnabled = true
		} else {
			self.navigationItem.rightBarButtonItem?.isEnabled = false
		}
		
	}
	
	
	//재귀함수를 만들어보쟈.
	func locateSelectedFolder(targetArray:[BookmarkData], searchKeyword:String) -> BookmarkData? {
		
		for data in targetArray {
			let child = data.child
			if child.count != 0 {
				if let searchData = locateSelectedFolder(targetArray: child, searchKeyword: searchKeyword) {
					return searchData
				}
			}
			
			print("data.titleString : \(data.titleString ?? "??")")
			if data.titleString == searchKeyword {
				//찾았다!
				print("찾았다 : \(data)")
				return data
			}
		}
		
		print("못찾았다.... 뭔가 이상함. \(searchKeyword)")
		return nil
	}
	
	@objc func saveFolder() {
		guard let selectedIndexPath = self.selectedIndexPath else {return}
		guard let selectedNode = self.selectedNode else { return}

		///New title input here
		guard let title = self.titleTextField.text, !title.isEmpty else { return }
		let origin = UserDefaultsManager.shared.loadUserBookMarkListData()
		guard let edittedFolderTitle = self.folderTitleInputText else { return }
		
		/// 제일 처음 아무 폴더도 없을떄????????
		if caseType == .AddNewFolder { /// 새로운 폴더를 추가하려고 할때
			if UserDefaultsManager.shared.isNameDuplicate(targetDatas: origin, title: title) {
					let alert = UIAlertController.init(title: "Duplicate Folder Name", message: nil, preferredStyle: UIAlertController.Style.alert)
					let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: nil)
					alert.addAction(okAction)
					self.present(alert, animated: true, completion: nil)
			} else {
				self.insertFolderAtSelectedLocation(folderTitle: title, selectNodeIndexs: self.selectNodeIndexs)
			}
		}

		if caseType == .EditFolder { /// 기존 데이터 (폴더이름) 을 수정 할때
			// 만약에 고친 폴더 이름이 원래 있던 폴더 이름과 같다면 그냥 pop.

			// 만약에 고친 폴더 이름이 다르다면 원본데이터에 고친 이름이 같은 폴더가 있는지 확인해야 함.


			/// Editting folder title here
			guard let edittedFolderTitle = self.folderTitleInputText else {
				return
			}

			self.treeView.isUserInteractionEnabled = false
			editFolderNameAtSelectedLocation(edittedFolderTitle: edittedFolderTitle)

		}
		
		// input 에 있는 텍스트가 원본 데이터를 돌며 duplicate 가 있는지 확인한다.
			if UserDefaultsManager.shared.isNameDuplicate(targetDatas: origin, title: title) {
				if caseType == .AddNewFolder { //추가 시에는 같은 이름의 폴더 추가를 불가
					let alert = UIAlertController.init(title: "Duplicate Folder Name", message: nil, preferredStyle: UIAlertController.Style.alert)
					let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: nil)
					alert.addAction(okAction)
					self.present(alert, animated: true, completion: nil)
				}
				if caseType == .EditFolder { //수정 시에는 변경된 폴더 이름이 원본에 있으면 불가
					if UserDefaultsManager.shared.isNameDuplicate(targetDatas: origin, title: edittedFolderTitle) { //중복이 있는지를 edittedFolderTitle 과 비교해 한번 더 돈다.
						let alert = UIAlertController.init(title: "Duplicate Folder Name", message: nil, preferredStyle: UIAlertController.Style.alert)
						let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: nil)
						alert.addAction(okAction)
						self.present(alert, animated: true, completion: nil)
					}
					else { //변경된 폴더이름이 다르다면
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
							self.navigationController?.popViewController(animated: true)
						}
					}
				}
			}
		else { // duplicate 이 없다면
			if caseType == .AddNewFolder { //해당 위치에 폴더 타이틀을 가져와 insert 한다.
				self.insertFolderAtSelectedLocation(folderTitle: title, selectNodeIndexs: self.selectNodeIndexs)
			}
			if caseType == .EditFolder { //treeview 의 다른 row 를 선택 불가로 만들고 그 위치의 폴더이름을 변경한다.
				self.treeView.isUserInteractionEnabled = false
				self.editFolderNameAtSelectedLocation(edittedFolderTitle: edittedFolderTitle)
			}
		}
		self.insertFolderAtSelectedLocation(folderTitle: title, selectNodeIndexs: self.selectNodeIndexs)
		
	}
	
	func editFolderNameAtSelectedLocation(edittedFolderTitle: String) {
		if let folderTitle = folderTitle {
			let editTargetData = locateSelectedFolder(targetArray: (self.bookmarkData as! [BookmarkData]), searchKeyword: folderTitle)
			editTargetData?.titleString = edittedFolderTitle
			self.editTargetData = editTargetData
		}
		let isSaveSuccess = UserDefaultsManager.shared.saveBookMarkListData(bookmarkD: bookmarkData as! [BookmarkData])
		print("Editing Folder Name at Selected Location success?: ", isSaveSuccess)
		treeView.reloadData()
		treeView.expandAllRows()
	}
	
	
//	func insertFolderAtSelectedLocation(indexPath: IndexPath, selectedNode: CITreeViewNode, title: String) {
//		let newFolder = BookmarkData.init(titleString: title, child: [], indexPath: [indexPath.row])
//
//		var array = UserDefaultsManager.shared.loadUserBookMarkListData()
//
//		if let selectedNodeItem = selectedNode.item as? BookmarkData {
//			print(selectedNodeItem.dataIndexPath)
//			array[indexPath.row].child.append(newFolder)
//		}
//
////		array.append(newFolder)
//
//		let isSaveSuccess = UserDefaultsManager.shared.saveBookMarkListData(bookmarkD: array)
//		print(isSaveSuccess)
//
//	}
	
	func insertFolderAtSelectedLocation(folderTitle:String, selectNodeIndexs:[Int]) {
		let appendFolder = BookmarkData.init(titleString: folderTitle, child: [], indexPath: selectNodeIndexs)
		
		if selectNodeIndexs.count == 0 {
			//self.bookmarkData.append(appendFolder)
			self.bookmarkData.add(appendFolder)
		} else {
			
			var data:BookmarkData?
			for index in selectNodeIndexs {
				if data == nil {
					//data = self.bookmarkData[index]
					data = self.bookmarkData.object(at: index) as! BookmarkData
				} else {
					data = data?.child[index]
				}
			}
			
			data?.child.append(appendFolder)
		}
		
		let isSaveSuccess = UserDefaultsManager.shared.saveBookMarkListData(bookmarkD: bookmarkData as! [BookmarkData])
		print("Inserting Folder at Selected Location success?: ", isSaveSuccess)
//		UserDefaultsManager.shared.updateBookmarkListDataNoti() //?????????
		treeView.reloadData()
		treeView.expandAllRows()
	}
	

	
}
//MARK: - TextField Delegate
extension EditFolderVC: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		print("textfieldDidEndEditing!!")

		
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		print("textFieldShouldReturn")
		self.folderTitleInputText = self.titleTextField.text
		
		textField.resignFirstResponder()
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)

		if !text.isEmpty {
			self.navigationItem.rightBarButtonItem?.isEnabled = true
		}
		else {
			self.navigationItem.rightBarButtonItem?.isEnabled = false
		}
		return true
	}
	
	
}

//MARK: - CITreeView Delegate
extension EditFolderVC: CITreeViewDelegate {
	func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
		print("willExpand")
		
//		if caseType == .EditFolder {
//			if let target = treeViewNode.item as? BookmarkData {
//				if let editTarget = self.editTargetData {
//					if target.titleString == editTarget.titleString {
//						self.treeView.selectRow(at: atIndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
//					}
//				}
//			}
//		}
		
		
	}
	
	func didExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
		print("didExpand")
//		if atIndexPath.row == 0 {
//			treeView.expandAllRows()
//		}
		
		
	}
	
	func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
		print("willCollapse")
	}
	
	func didCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
		print("didCollapse")
//		if atIndexPath.row == 0 {
//			treeView.collapseAllRows()
//		}
	}
	
	func treeView(_ treeView: CITreeView, heightForRowAt indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode) -> CGFloat {
		return 40
	}
	
	func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode: CITreeViewNode, atIndexPath indexPath: IndexPath) {
		
		if let selectedNode = treeViewNode.self.item as? BookmarkData {
			
			self.selectedNode = treeViewNode
			self.selectedIndexPath = indexPath
			
			var selectNodeTitle:String = selectedNode.titleString ?? ""
			
			selectNodeIndexs.removeAll()
			var parentNode:CITreeViewNode? = treeViewNode
			
			repeat {
				if let nowNode = parentNode {
					parentNode = nowNode.parentNode
					
					if let parentBookMark = parentNode?.item as? BookmarkData {
						
						for index in 0..<parentBookMark.child.count {
							let item = parentBookMark.child[index]
							//------------------- trying to find the selected Folder to edit
//							if item.titleString == folderTitle {
//								treeView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
//								print("Found Item at: ", indexPath)
//							}
							//-------------------
							if item.titleString == selectNodeTitle {
								///찾았다?
								selectNodeIndexs.insert(index, at: 0)
								selectNodeTitle = parentBookMark.titleString ?? ""
								break
							}
							
						}
					}
					
				} else {
					parentNode = nil
				}
			} while parentNode != nil
			
			//root
			for index in 0..<self.bookmarkData.count {
				let rootItem = self.bookmarkData[index] as! BookmarkData
//				if rootItem.titleString == folderTitle {
//					treeView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
//				}
				if rootItem.titleString == selectNodeTitle {
					selectNodeIndexs.insert(index, at: 0)
					break
				}
			}
			
			print("selectNodeIndexs \(selectNodeIndexs)")
			
//			let alertController = UIAlertController(title: folderTitleInputText, message: "indexPath:" + String(describing: indexPath) + "\n" + "dataIndexPath:" + String(describing: selectedNode.dataIndexPath) + "\n"
//				, preferredStyle: UIAlertController.Style.alert)
//			let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
//			alertController.addAction(cancelAction)
//			self.present(alertController, animated: true, completion: nil)
			/// 선택한 노드가 폴더일때만 새로 만든 폴더가 그 안에 있어야 한다. indexpath 로 위치를 잡을 것이 아니라 자식 안에도 만들 수 있어야 한다. 그렇다면 폴더를 닫으면 index가 바뀌기 때문에 절대 경로(데이터)를 기준으로 생성해야 한다.?
//			if selectedNode.isFolder{
//				insertFolderAtSelectedLocation(indexPath: indexPath, selectedNode: treeViewNode, title: folderTitleInputText!)
//			}

		}
		
	}
	
	func treeView(_ treeView: CITreeView, didDeselectRowAt treeViewNode: CITreeViewNode, atIndexPath indexPath: IndexPath) {
		if let selectedNode = treeViewNode.self.item as? BookmarkData {
//			if let cell = treeView.cellForRow(at: indexPath) {
//				cell.accessoryType = .none
//			}
			
			
		}
		
		
	}
	
	
}

//MARK: - CITreeView DataSource
extension EditFolderVC: CITreeViewDataSource {
	func treeViewSelectedNodeChildren(for treeViewNodeItem: AnyObject) -> [AnyObject] {
		if let dataObj = treeViewNodeItem as? BookmarkData {
			return dataObj.child as [AnyObject]
		}
		return []
	}
	
	func treeViewDataArray() -> [AnyObject] {
//		data.filter { (bookmarkdata) -> Bool in
//			bookmarkdata.isFolder
//		}
//		let filteredData = data.filter { $0.isFolder }
		
//		if let bookmarkData = self.bookmarkData as? [BookmarkData] {
//			let filteredData = bookmarkData.filter { (item) -> Bool in
//				let temp = item.isFolder
//				if !temp {
//					print("isn't folder")
//				}
//				return temp
//			}
//
//			return filteredData as [AnyObject]
//		}
		
		//FIXME: - FILTERING FOLDER DATA ONLY???????
//		let filteredData = bookmarkData.filter { (item) -> Bool in
//			guard let item = item as? BookmarkData else { return false }
//			let folders = item.isFolder
//
//			return folders
//		}
//		return filteredData as [AnyObject]
		
		return bookmarkData as [AnyObject]
	}
	
	func treeView(_ treeView: CITreeView, atIndexPath indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode) -> UITableViewCell {
		treeView.allowsSelection = true
		
		let cell = treeView.dequeueReusableCell(withIdentifier: "folderCell") as! FolderCell
		
		let dataObj = treeViewNode.item as! BookmarkData
		
		cell.setupIconFolderOrBook(dataObj)
		
		cell.folderName.text = dataObj.titleString
		cell.setupCell(level: treeViewNode.level)
		
		//FIXME: - child folder selection is not abled. ㅠㅠ
		if !dataObj.isFolder {
			cell.isUserInteractionEnabled = false
		}
		
		if caseType == .EditFolder {
			cell.isUserInteractionEnabled = false
			if let target = treeViewNode.item as? BookmarkData {
				if let editTarget = self.editTargetData {
					if target.titleString == editTarget.titleString {
						self.treeView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
					}
				}
			}
		}
		
		return cell
	}
	
	
}
