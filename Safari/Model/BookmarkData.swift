//
//  BookmarkData.swift
//  Safari
//
//  Created by 변재우 on 20200212//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit

class BookmarkData: NSObject, Codable {
	
	enum expressionKeys: String {
		case titleString
		case urlString
	}
	
	@objc let urlString: String?
	@objc var titleString: String?
	let iconUrlString: String?
	let dataIndexPath:[Int]?
	var child: [BookmarkData] = []
	var isFolder: Bool {
		get {
			let temp = (urlString?.isEmpty ?? true) ? true : false
			return temp
		}
	}
	
	/// initializing Bookmark Data
	init(urlString: String, titleString: String, iconUrlString: String = "", indexPath: [Int]) {
		self.urlString = urlString
		self.titleString = titleString
		self.iconUrlString = iconUrlString
		self.dataIndexPath = indexPath
	}
	
	/// initializing Folder Data
	init(titleString: String, child: [BookmarkData], indexPath: [Int]) {
		self.urlString = nil
		self.titleString = titleString
		self.iconUrlString = ""
		self.child = child
		
		self.dataIndexPath = indexPath
	}

//	required init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		titleString = try container.decodeIfPresent(String.self, forKey: .titleString)
//		urlString = try container.decodeIfPresent(String.self, forKey: .urlString)
//		iconUrlString = try container.decodeIfPresent(String.self, forKey: .iconUrlString)
//		dataIndexPath = nil
//	}
//
//	func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(titleString, forKey: .titleString)
//		try container.encode(urlString, forKey: .urlString)
//		try container.encode(iconUrlString, forKey: .iconUrlString)
//	}
	
	func getBookmarkTitle() -> String? {
		if isFolder { return nil }
		return titleString
	}
	
	func getBookmarkUrl() -> URL? {
		if isFolder { return nil }
		if let url = URL.init(string: urlString ?? "") {
			return url
		}
		return nil
	}
	
	func getIconUrl() -> URL? {
		if isFolder { return nil }
		if let url = URL.init(string: iconUrlString ?? "") {
			return url
		}
		return nil
	}
	
	//	//For Tree Sytle data
	//	mutating func addChild(_ child: BookmarksData) {
	//		self.child.append(child)
	//	}
	//
	//	mutating func removeChild(_ child: BookmarksData) {
	////		self.child = self.child.filter({ $0 !== child })
	//	}
	
	
	
}

/// mockData
class BookmarksDataModel {
	static var mockDataArray = ["www.google.com", "www.m.naver.com", "www.apple.com", "www.github.com", "www.facebook.com"]
	
	static var bookMarkDatas: [BookmarkData] = []
	
	static func createSampleData() {
		
		var temp: [BookmarkData] = []
		
		for folderIndex in 0..<10 {
			//append 10 folders
			var child: [BookmarkData] = []
			
			for bookmarkIndex in 0..<5 {
				//append 5 folders for each top folder
				
				let dataIndex:[Int] = [0, folderIndex, bookmarkIndex]
				let childItem = BookmarkData.init(urlString: "http://\(mockDataArray[bookmarkIndex])", titleString: "\(mockDataArray[bookmarkIndex])", indexPath: dataIndex)
				child.append(childItem)
			}
			
//			let grandchild = BookmarksData.init(urlString: "bookmark", titleString: "Grandchild Bookmark")
//			let bookmarkChildItem = BookmarksData.init(titleString: "folder 5", child: [grandchild])
//			child.append(bookmarkChildItem)
			
			let dataIndex:[Int] = [0, folderIndex]
			let folderData = BookmarkData.init(titleString: "folder_ \(folderIndex)", child: child, indexPath: dataIndex)
			temp.append(folderData)
		}
		
		let dataIndex:[Int] = [0, temp.count]
		let tempBookmark = BookmarkData.init(urlString: "http://???.com", titleString: "This is a bookmark", indexPath: dataIndex)
//		bookMarkDatas.append(tempBookmark)
		temp.append(tempBookmark)
//		print(temp)
		
		bookMarkDatas.removeAll()
//		bookMarkDatas.append(contentsOf: temp)
		//
		
		let firstdataIndex:[Int] = [0]
		let favorites = BookmarkData.init(titleString: "Favorites", child: temp, indexPath: firstdataIndex)
		bookMarkDatas.append(favorites)
		
		
		
	}
	
}
