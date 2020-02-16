//
//  BookmarkData.swift
//  Safari
//
//  Created by 변재우 on 20200212//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit

class BookmarkData: Codable {
	let urlString: String?
	var titleString: String?
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
