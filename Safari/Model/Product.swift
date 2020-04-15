//
//  Product.swift
//  Safari
//
//  Created by 변재우 on 20200328//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation

class Product: NSObject, Codable {
	
	enum CodingKeys: String, CodingKey {
		case title
		case urlAddress
	}
	
	/// NSPredicate expression keys for searching
	enum ExpressionKeys: String {
		case title
		case urlAddress
	}
	
	enum ProductType: Int, CaseIterable {
		case all = 0
		case wikipedia = 1
		case bookmarks = 2
		case history = 3
		case readingList = 4
		case onThisPage = 5
	}
	
	class func productTypeName(forType: ProductType) -> String {
		switch forType {
		case .all:
			return NSLocalizedString("AllTitle", comment: "")
		case .wikipedia:
			return NSLocalizedString("Wikipedia", comment: "")
		case .bookmarks:
			return NSLocalizedString("Bookmarks", comment: "")
		case .history:
			return NSLocalizedString("History", comment: "")
		case .readingList:
			return NSLocalizedString("ReadingList", comment: "")
		case .onThisPage:
			return NSLocalizedString("OnThisPage", comment: "")
		}
	}
	
	// MARK: - Properties
	
	@objc var title: String
	@objc var urlAddress: String
	
	// MARK: - Initializers
	
	init(title: String, urlAddress: String) {
		self.title = title
		self.urlAddress = urlAddress
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		title = try container.decode(String.self, forKey: .title)
		urlAddress = try container.decode(String.self, forKey: .urlAddress)
	}
	
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(title, forKey: .title)
		try container.encode(urlAddress, forKey: .urlAddress)
	}
	
}
