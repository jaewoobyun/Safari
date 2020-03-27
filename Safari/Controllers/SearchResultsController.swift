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
	let sectionLists = ["Top Hits", "Google Search", "Bookmarks and History", "On This Page"]
	var topHitsData = ["a","b","c","d"]
	var googleSearchData = ["e","f","g"]
	var bookmarksAndHistoryData = ["h","i","j"]
	var historyData: [HistoryData] = []
	var onThisPageData = ["k","l","m"]
	
	/// Search Controller to help us with filtering items in the table view
	var searchController: UISearchController!
	
	/// Search results table view
	private var resultsTableController: ResultsTableController!
	
	/// Restoration state for UISearchController
//	var restoredState = SearchControllerRestorableState()
	
	var searchText: String?
	var isSearchBarEmpty: Bool?
	var isFiltering: Bool?
	
	var originalData: [String] = []
	var displayData: [String] = []
	var filteredData: [String] = []
	
	
	// MARK: - View Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// ----------------
//		resultsTableController = self.storyboard?.instantiateViewController(identifier: "ResultsTableController") as? ResultsTableController
//		// This view Controller is interested in the table view row selections.
//		resultsTableController.tableView.delegate = self
//
//		searchController = UISearchController(searchResultsController: resultsTableController)
//		searchController.delegate = self
//		searchController.searchResultsUpdater = self
//		searchController.searchBar.autocapitalizationType = .none
//		searchController.searchBar.delegate = self // Monitor when the search button is tapped.
//
//		// Place the search bar in the navigation bar.
//		navigationItem.searchController = searchController
//
//		// Make the search bar always visible.
////		navigationItem.hidesSearchBarWhenScrolling = true //
//
//		definesPresentationContext = true
//
//		
//
		
		// ----------------
		
		
//		bookmarksAndHistoryData = UserDefaults.standard.stringArray(forKey: "HistoryData") ?? [String]()
//		bookmarksAndHistoryData = UserDefaultsManager.shared.visitedWebSiteHistoryRecords
		
		
		
//		historyData = UserDefaultsManager.shared.visitedWebSiteHistoryRecordss
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		UserDefaultsManager.shared.registerHistoryDataObserver(vc: self, selector: #selector(updateHistoryData))
		UserDefaultsManager.shared.loadUserHistoryData()
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

extension SearchResultsController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		originalData = bookmarksAndHistoryData
		
		self.searchController = searchController //????
		searchText = searchController.searchBar.text!
		isSearchBarEmpty = { searchController.searchBar.text?.isEmpty ?? true }()
		isFiltering = { searchController.isActive && !(isSearchBarEmpty ?? true) }()
		
		DispatchQueue.main.async {
			self.filterContentForSearchText(self.searchText!) //
			self.tableView.reloadData()
		}
		
	}
	
	func filterContentForSearchText(_ searchText: String) {
		filteredData = originalData.filter({ (string) -> Bool in
			Jamo.getJamo(string.lowercased()).contains(Jamo.getJamo(searchText.lowercased()))
		})
		tableView.reloadData()
	}
	
	
}

// MARK: - UITableViewDataSource
extension SearchResultsController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sectionLists.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sectionLists[section]
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return topHitsData.count
		case 1:
			return googleSearchData.count
		case 2:
//			if isFiltering! {
//				return filteredData.count
//			}
//			return bookmarksAndHistoryData.count
			return historyData.count
		case 3:
			return onThisPageData.count
		default:
			return 1
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath)
		
		switch indexPath.section {
		case 0:
			cell.textLabel?.text = topHitsData[indexPath.row]
			cell.detailTextLabel?.text = "detail"
		case 1:
			cell.textLabel?.text = googleSearchData[indexPath.row]
			cell.detailTextLabel?.text = "detail"
		case 2:
//			if isFiltering! {
//				cell.textLabel?.text = filteredData[indexPath.row]
//				cell.detailTextLabel?.text = "FOUND IT"
//			}
//			cell.textLabel?.text = bookmarksAndHistoryData[indexPath.row]
			cell.textLabel?.text = historyData[indexPath.row].title
			cell.detailTextLabel?.text = "detail"
		case 3:
			cell.textLabel?.text = topHitsData[indexPath.row]
			cell.detailTextLabel?.text = "detail"
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
			print("0 top search?")
		case 1:
			print("1 google search?")
		case 2:
			print("2 bookmarks and history?")
		case 3:
			print("3 on this page?")
		default:
			print("default")
		}
	}
}


// MARK: - UISearchBarDelegate ??

// MARK: - UISearchControllerDelegate





