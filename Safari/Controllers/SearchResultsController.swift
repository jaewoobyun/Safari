//
//  SearchResultsController.swift
//  Safari
//
//  Created by 변재우 on 20200324//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit

class SearchResultsController: UITableViewController {
	
	// MARK: - Properties
	
	/// Data Models
	let sectionLists = ["Wikipedia", "History", "Bookmarks", "ReadingList", "On This Page"]
//	var topHitsData = ["a","b","c","d"]
//	var googleSearchData = ["e","f","g"]
//	var bookmarksAndHistoryData = ["h","i","j"]
	
	var wikipediaData: [String] = []
	var wikipediaUrlStrings: [String] = []
	var historyData: [HistoryData] = []
	var bookmarkData: [BookmarkData] = []
	var readingListData: [ReadingListData] = []
	var onThisPageData = ["a","b","c","d","e","f","g","h","i","j","k","l","m"]
	
	/// Search Controller to help us with filtering items in the table view
	var searchController: UISearchController!
	
	var searchText: String?
	var isSearchBarEmpty: Bool?
	var isFiltering: Bool?
	
	var originalData: [String] = []
	var displayData: [String] = []
	var filteredData: [String] = []
	
	var filteredWikipediaData = [String]()
	var filteredWikipediaURLStrings = [String]()
	var filteredHistoryData = [HistoryData]()
	var filteredBookmarkData = [BookmarkData]()
	var filteredReadingListData = [ReadingListData]()
	
	// MARK: - View Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		

	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		UserDefaultsManager.shared.registerHistoryDataObserver(vc: self, selector: #selector(updateHistoryData))
		UserDefaultsManager.shared.loadUserHistoryData()
		
		UserDefaultsManager.shared.registerBookmarkDataObserver(vc: self, selector: #selector(updateBookmarkData))
		UserDefaultsManager.shared.initDatas()
		
		bookmarkData = UserDefaultsManager.shared.loadUserBookMarkListData()
		bookmarkData = bookmarkData.filter { (bookmarkData) -> Bool in
			!bookmarkData.isFolder && bookmarkData.child.isEmpty
		}
//		bookmarkData = bookmarkData.filter { (bookmarkData) -> Bool in
//			!bookmarkData.isFolder && bookmarkData.child.isEmpty
//			var notFolderItems: [BookmarkData] = []
//			for item in self.bookmarkData {
//				notFolderItems = item.child
//			}
//			return notFolderItems.
//		}
		
		UserDefaultsManager.shared.registerReadingListDataObserver(vc: self, selector: #selector(updateReadingListData))
		UserDefaultsManager.shared.loadUserReadingListData()
	}
	
	@objc func updateReadingListData() {
		print("SearchResultsController updated ReadingList Data")
		readingListData.removeAll()
		readingListData = UserDefaultsManager.shared.readingListRecords
		tableView.reloadData()
	}
	
	@objc func updateBookmarkData() {
		print("SearchResultsController updated Bookmark Data")
		bookmarkData.removeAll()
		bookmarkData = UserDefaultsManager.shared.bookmarkRecords
		bookmarkData = bookmarkData.filter { (bookmarkData) -> Bool in
			!bookmarkData.isFolder && bookmarkData.child.isEmpty
		}
		tableView.reloadData()
	}
	
	@objc func updateHistoryData() {
		print("SearchResultsController updated History Data")
		historyData.removeAll()
		historyData = UserDefaultsManager.shared.visitedWebSiteHistoryRecords
		
		tableView.reloadData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Restore the searchController's active state.
//		if restoredState.wasActive {
//			searchController.isActive = restoredState.wasActive
//			restoredState.wasActive = false
//
//			if restoredState.wasFirstResponder {
//				searchController.searchBar.becomeFirstResponder()
//				restoredState.wasFirstResponder = false
//			}
//		}
	}
	
}

// MARK: - UITableViewDataSource
extension SearchResultsController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sectionLists.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		return sectionLists[section]
		var title = ""
		switch section {
		case 0:
			title = Product.productTypeName(forType: .wikipedia)
		case 1:
			title = Product.productTypeName(forType: .bookmarks)
		case 2:
			title = Product.productTypeName(forType: .history)
		case 3:
			title = Product.productTypeName(forType: .readingList)
		case 4:
			title = Product.productTypeName(forType: .onThisPage)
		default:
			break
		}
		
		return title
		
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
//			if isFiltering == true {
//				return filteredData.count
//			}
//			else {
//				return topHitsData.count
//			}
			
			if isFiltering == true {
				return filteredWikipediaData.count
			}
			else {
				return wikipediaData.count
			}
		case 1:
			if isFiltering == true {
				return filteredBookmarkData.count
			}
			else {
//				let justBookmarkData = bookmarkData.filter { (bookmarkData) -> Bool in
//					!bookmarkData.isFolder && bookmarkData.child.isEmpty
//				}
				return bookmarkData.count
			}
		case 2:
			if isFiltering == true {
				return filteredHistoryData.count
			}
			else {
				return historyData.count
			}
		case 3:
			if isFiltering == true {
				return filteredReadingListData.count
			}
			else {
				return readingListData.count
			}
		case 4:
			if isFiltering == true {
				return filteredData.count
			}
			else {
				return originalData.count
			}
		default:
			return 1
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath)
		
		switch indexPath.section {
		case 0:
//			cell.textLabel?.text = topHitsData[indexPath.row]
//			if isFiltering == true {
//				cell.textLabel?.text = filteredData[indexPath.row]
//				cell.detailTextLabel?.text = "detail" + filteredData[indexPath.row]
//			}
			
			if isFiltering == true {
				cell.textLabel?.text = filteredWikipediaData[indexPath.row]
				cell.detailTextLabel?.text = filteredWikipediaURLStrings[indexPath.row]
			} else {
				cell.textLabel?.text = wikipediaData[indexPath.row]
			}
		case 1:
//			let justBookmarkData = bookmarkData.filter { (bookmarkData) -> Bool in
//				!bookmarkData.isFolder && bookmarkData.child.isEmpty
//			}
			cell.textLabel?.text = bookmarkData[indexPath.row].titleString
			cell.detailTextLabel?.text = bookmarkData[indexPath.row].urlString
			if isFiltering == true {
				cell.textLabel?.text = filteredBookmarkData[indexPath.row].titleString
				cell.detailTextLabel?.text = filteredBookmarkData[indexPath.row].urlString
			}
		case 2:
			cell.textLabel?.text = historyData[indexPath.row].title
			cell.detailTextLabel?.text = historyData[indexPath.row].urlString
			if isFiltering == true {
				cell.textLabel?.text = filteredHistoryData[indexPath.row].title
				cell.detailTextLabel?.text = filteredHistoryData[indexPath.row].urlString
			}
		case 3:
			cell.textLabel?.text = readingListData[indexPath.row].title
			cell.detailTextLabel?.text = readingListData[indexPath.row].urlString
			if isFiltering == true {
				cell.textLabel?.text = filteredReadingListData[indexPath.row].title
				cell.detailTextLabel?.text = filteredReadingListData[indexPath.row].urlString
			}
		case 4:
			cell.textLabel?.text = originalData[indexPath.row]
			if isFiltering == true {
				cell.textLabel?.text = filteredData[indexPath.row]
			}
		default:
			return cell
		}
		
		return cell
	}
	
}

// MARK: - UITableViewDelegate
extension SearchResultsController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			print("0 wikipedia?")
//			guard let filteredWikiURLs = filteredWikipediaURLStrings[indexPath.row] else { return }
			let filteredWikiURL = filteredWikipediaURLStrings[indexPath.row]
			self.dismiss(animated: true) {
				NotificationGroup.shared.post(type: .bookmarkURLName, userInfo: ["selectedBookmarkURL": filteredWikiURL])
			}
		case 1:
			print("2 bookmarks")
			guard let urlString = bookmarkData[indexPath.row].urlString else { return }
			self.dismiss(animated: true) {
				NotificationGroup.shared.post(type: .bookmarkURLName, userInfo: ["selectedBookmarkURL": urlString])
			}
		case 2:
			print("3 history")
//			guard let urlString = filteredHistoryData[indexPath.row].urlString else { return }
//			self.dismiss(animated: true) {
//				NotificationGroup.shared.post(type: .historyURLName, userInfo: ["selectedHistoryURL": urlString])
//			}
			if isFiltering == true {
				guard let urlString = filteredHistoryData[indexPath.row].urlString else { return }
				self.dismiss(animated: true) {
					NotificationGroup.shared.post(type: .historyURLName, userInfo: ["selectedHistoryURL": urlString])
				}
			} else {
				guard let urlString = historyData[indexPath.row].urlString else { return }
				self.dismiss(animated: true) {
					NotificationGroup.shared.post(type: .historyURLName, userInfo: ["selectedHistoryURL": urlString])
				}
			}
			
			
		case 3:
			print("4 readingList")
			if isFiltering == true {
				guard let urlString = filteredReadingListData[indexPath.row].urlString else { return }
				self.dismiss(animated: true) {
					NotificationGroup.shared.post(type: .readinglistURLName, userInfo: ["selectedReadingListURL": urlString])
				}
			}
			else {
				guard let urlString = readingListData[indexPath.row].urlString else { return }
				self.dismiss(animated: true) {
					NotificationGroup.shared.post(type: .readinglistURLName, userInfo: ["selectedReadingListURL": urlString])
				}
			}
			
		case 4:
			print("5 on this page?")
			if isFiltering == true {
				print("Filtering!!!")
				print(filteredData[indexPath.row])
			}
			else {
				print("isn't filtering!!")
				print(originalData[indexPath.row])
			}
		default:
			print("default")
		}
	}
}


// MARK: - UISearchBarDelegate ??

// MARK: - UISearchControllerDelegate





