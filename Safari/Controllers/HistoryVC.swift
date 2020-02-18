//
//  HistoryVC.swift
//  Safari
//
//  Created by 변재우 on 20200212//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit

class HistoryVC: UITableViewController {
	
	let searchController = UISearchController(searchResultsController: nil)
	lazy var searchBar = UISearchBar(frame: CGRect.zero)
	
	let dateFormatter = DateFormatter()
	let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
	
	var historyData: [HistoryData] = []
	
	struct Section {
		var date: Date
		var cells: [HistoryData]
	}
	var sections: [Section] = []
	
	
	// MARK: - LifeCycle
	override func viewDidLoad() {
		self.title = "History"
		self.navigationController?.navigationBar.isHidden = false
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.tableHeaderView = searchController.searchBar
		
//		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "historycellsample")
		
	}
	
	/// 원본 데이터의 순서가 다를 수 있기 때문에 순번대로 바꿔준다. 아래 코드가 실행되는 기준이 원본데이터가 정렬되있다고 가정하고 짜여진 코드이기 때문에.
	func sortHistoryDataDatesByTopNewBottomOld() {
		historyData.sort { (h1, h2) -> Bool in
			guard let h1Date = h1.date else {
				return false
			}
			guard let h2Date = h2.date else {
				return false
			}
			
			return (h1Date > h2Date)
		}
	}
	
	/// 원본 데이터를 화면에 뿌리기 좋게 가공한다.
	func sectionize() {
		sections.removeAll()
		
		sortHistoryDataDatesByTopNewBottomOld()
		var beforeItem: HistoryData? = nil
		
		//원본 데이터를 전부 돌린다.
		for item in historyData {
			//현재 순서의 날짜를 빼둔다. 날짜가 없다면 현재 날짜가 된다.
			let nowDate = item.date ?? Date()
			
			//바로 직전 루프의 아이템 날짜값과 현재 아이템의 날짜값이 같은지 비교한다.
			if let beforeDate = beforeItem?.date, calendar.isDate(beforeDate, inSameDayAs: nowDate) {
				sections[sections.count - 1].cells.append(item)
			}
			else {
				//이전 아이템과 현재 아이템의 날짜가 다르다.
				//섹션에 추가될 cells를 먼저 생성하고, 현재 루프의 아이템을 추가한다.
				var arrItems: [HistoryData] = []
				arrItems.append(item)
				
				//새로운 섹션을 만들어서 sections 에 추가한다.
				let section = Section.init(date: nowDate, cells: arrItems)
				
				//sections 에 배정한다.
				sections.append(section)
			}
			//beforeItem 은 한번의 루프가 돌때 다음 아이템이 된다. historyData[0] ---> historyData[1]
			beforeItem = item
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		self.navigationController?.navigationBar.isHidden = false
		UserDefaultsManager.shared.registerHistoryDataObserver(vc: self, selector: #selector(updateHistoryData))
		UserDefaultsManager.shared.loadUserHistoryData()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		UserDefaultsManager.shared.removeHistoryDataObserver()
	}
	
	@objc func updateHistoryData() {
		//데이터가 업데이트 되었다.
		print("historyVC updateHistoryData")
		historyData.removeAll()
		historyData = UserDefaultsManager.shared.visitedWebSiteHistoryRecords
		
		sectionize()
		tableView.isUserInteractionEnabled = true
		tableView.reloadData()
	}
	
	@IBAction func clearButton(_ sender: UIBarButtonItem) {
		Alerts.shared.makeClearHistoryAlert(viewController: self, lastHourHandler: { (action) in
			UserDefaultsManager.shared.removeHistoryDataAtLastHour(1)
		}, todayHandler: { (action) in
			UserDefaultsManager.shared.removeHistoryDataAtLastHour(24)
		}, todayAndYesterdayHandler: { (action) in
			UserDefaultsManager.shared.removeHistoryDataAtLastHour(48)
		}) { (action) in
			UserDefaultsManager.shared.removeAllHistoryData()
		}
			
	}
	
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		dateFormatter.locale = Locale(identifier: "ko_kr")
		dateFormatter.dateFormat = "EEEE, MMMM d" // ex) "화요일, 12월 17"
		
		let dateString = dateFormatter.string(from: sections[section].date)
		return dateString
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].cells.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
		cell.detailTextLabel?.textColor = UIColor.gray
		
		if let titleString = sections[indexPath.section].cells[indexPath.row].title {
			cell.textLabel?.text = titleString
		}
		if let visitedDate = sections[indexPath.section].cells[indexPath.row].date {
			dateFormatter.locale = Locale(identifier: "ko_kr")
			dateFormatter.dateFormat = "EEEE, MMMM d HH:mm" // ex) "화요일, 12월 17"
			let visitedDateString = dateFormatter.string(from: visitedDate)
			if let urlString = sections[indexPath.section].cells[indexPath.row].urlString {
				cell.detailTextLabel?.text = visitedDateString + " " + urlString
			}
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("didSelectRowAt \(indexPath)")
		let urlString = sections[indexPath.section].cells[indexPath.row].urlString
		
		NotificationGroup.shared.post(type: .historyURLName, userInfo: ["selectedHistoryURL": urlString])
		self.dismiss(animated: true, completion: nil)
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .delete
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			/// 아이디는 먼저 빼돌린다.
			let selectedItemUUID = sections[indexPath.section].cells[indexPath.row].uuid
			
			// 디스플레이 데이터를 기반으로 애니메이션 실행.
			self.sections[indexPath.section].cells.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
			
			tableView.isUserInteractionEnabled = false
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				// 실물 데이터에서 삭제 요청.
				UserDefaultsManager.shared.removeHistoryItemAtUUID(selectedItemUUID)
			}
			
		}
	}
	
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (actions) -> UIMenu? in
			let deleteCancel = Menus.MenuActions.cancel.createButtonAction { (action) in
				print("cancel")
			}
			let deleteConfirmation = Menus.MenuActions.delete.createDeleteConfirmationMenu { (action) in
				/// 아이디는 먼저 빼돌린다.
				let selectedItemUUID = self.sections[indexPath.section].cells[indexPath.row].uuid
				// 디스플레이 데이터를 기반으로 애니메이션 실행.
				self.sections[indexPath.section].cells.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
				tableView.isUserInteractionEnabled = false
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					// 실물 데이터에서 삭제 요청
					UserDefaultsManager.shared.removeHistoryItemAtUUID(selectedItemUUID)
				}
				
			}
			
			let deleteAction = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [deleteCancel, deleteConfirmation])
			
			
			return UIMenu(title: "Menu", image: nil, identifier: nil, options: UIMenu.Options.init(), children: [
				///Copy
				Menus.MenuActions.copy.createButtonAction({ (action) in
					print("Copying", self.historyData[indexPath.row].urlString as Any)
					if let historyUrlString = self.historyData[indexPath.row].urlString {
						UIPasteboard.general.string = historyUrlString
					}
				}),
				///Open In New Tab
				Menus.MenuActions.openInNewTab.createButtonAction({ (action) in
					print("open In new tab action", action)
				}),
				///Delete [deleteConfirmation, delete cancel]
				deleteAction
			])
			
		}
	}
	
	override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		//
	}
	
}


extension HistoryVC: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		print("update SearchResults")
	}
}



