//
//  HistoryData.swift
//  Safari
//
//  Created by 변재우 on 20200212//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
//import UIKit

class HistoryData: NSObject, Codable {
	
	enum expressionKeys: String {
		case title
		case urlString
	}
	
	
	var url: URL? //ex)www.google.com//search?source... ???
	var initialUrl: URL? // 제일 첫 URL? ex) www.google.com ???
	@objc var title: String? //구글
	@objc var urlString: String?
	var date: Date? //방문한 시각
	var uuid: String = UUID.init().uuidString
	
	init(url: URL, initialUrl: URL, title: String, urlString: String, date: Date) {
		self.url = url
		self.initialUrl = initialUrl
		self.title = title
		self.urlString = urlString
		self.date = date
	}
	
//	required init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
////		url = try container.decode
//		title = try container.decode(String.self, forKey: .title)
//		urlString = try container.decode(String.self, forKey: .urlString)
//		uuid = try container.decode(String.self, forKey: .uuid)
//
//	}
//
//	func encoder(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(title, forKey: .title)
//		try container.encode(urlString, forKey: .urlString)
//		try container.encode(uuid, forKey: .uuid)
//	}
	
}
