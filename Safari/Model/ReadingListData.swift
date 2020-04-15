//
//  ReadingListData.swift
//  Safari
//
//  Created by 변재우 on 20200212//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit

class ReadingListData: NSObject, Codable {
	
	enum CodingKeys: String, CodingKey {
		case url
		case initialUrl
		case title
		case urlString
		case date
		case uuid
	}
	
	enum expressionkeys: String {
		case url
		case initialUrl
		case title
		case urlString
		case date
		case uuid
	}
	
	
	@objc var url: URL? //ex)www.google.com//search?source... ???
	@objc var initialUrl: URL? // 제일 첫 URL? ex) www.google.com ???
	@objc var title: String? //구글
	@objc var urlString: String?
	@objc var date: Date? //방문한 시각
	@objc var uuid: String = UUID.init().uuidString
	
	init(url: URL, initialUrl: URL, title: String, urlString: String, date: Date) {
		self.url = url
		self.initialUrl = initialUrl
		self.title = title
		self.urlString = urlString
		self.date = date
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		title = try container.decode(String.self, forKey: .title)
		urlString = try container.decode(String.self, forKey: .urlString)
		uuid = try container.decode(String.self, forKey: .uuid)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(title, forKey: .title)
		try container.encode(urlString, forKey: .urlString)
		try container.encode(uuid, forKey: .uuid)
	}
	
	func getFirstIconLetter() -> String {
		if let letter = title {
			if letter.isEmpty {
				return "?"
			}
			
			let first = letter[letter.startIndex]
			return String(first)
		}
		
		return "?"
	}
	
	func getIconLetterColor() -> UIColor {
		
		let iconText = getFirstIconLetter()
		//랜덤컬러를 지정하여 반환할것, 기준값은 icon text.
		
		var total: Int = 0
		for u in iconText.unicodeScalars {
			total += Int(UInt32(u))
		}
		
		srand48(total * 200)
		let r = CGFloat(drand48())
		
		srand48(total)
		let g = CGFloat(drand48())
		
		srand48(total / 200)
		let b = CGFloat(drand48())
		
		return UIColor(red: r, green: g, blue: b, alpha: 1)
	}
}

