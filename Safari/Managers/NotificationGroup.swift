//
//  NotificationGroup.swift
//  Safari
//
//  Created by 변재우 on 20200212//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit

class NotificationGroup {
		static let shared = NotificationGroup()
	
	private init(){
//		super.init() /// NotificationGroup 이 다른 class 를 상속하고 있을때는 상위 클래스의 초기화도 해준다
	}
	
	enum NotiType: String {
		/// notify ContainerVC's searchbar the changes of URL
		case urlUpdate
		/// notify WebView of the Bookmark URL
		case bookmarkURLName
		/// notify WebView of the ReadingList URL
		case readinglistURLName
		/// notify WebView of the HistoryList URL
		case historyURLName
		/// 우리가 WebView에서  추출하고 싶은 방문기록
		case historyDataInstance
		/// 백 버튼을 눌렀을때 쌓이는 과거 기록들 // 아직 안쓰임
		case backListData
		/// 앞으로 버튼 눌렀을때 쌓이는 기록들 // 아직 안쓰임
		case forwardListData
		///히스토리 데이터가 업데이트 됬을때 사용한다.
		case HistoryDataUpdate
		///리딩 리스트 데이터가 업데이트 됬을때 사용한다.
		case ReadingListDataUpdate
		///북마크 데이트가 업데이트 되었을때 사용한다.
		case BookmarkListDataUpdate
		/// 북마크에 탭 추가할때 사용
		case newTab
		/// 북마크에 여러 탭들을 추가할때 사용.
		case newTabsListDataUpdate
		
		/// Notification.Name 목록들.
		func getNotificationName() -> Notification.Name? {
			switch self {
			case .urlUpdate:
				return Notification.Name.init("urlUpdate")
			case .bookmarkURLName:
				return Notification.Name.init("bookmarkURLName")
			case .readinglistURLName:
				return Notification.Name.init("readinglistURLName")
			case .historyURLName:
				return Notification.Name.init("historyURLName")
			case .historyDataInstance:
				return Notification.Name.init("historyDataInstance")
			case .backListData:
				return Notification.Name.init("backListData")
			case .forwardListData:
				return Notification.Name.init("forwardListData")
				
			case .HistoryDataUpdate:
				return Notification.Name.init("HistoryDataUpdate")
			case .ReadingListDataUpdate:
				return Notification.Name.init("ReadingListDataUpdate")
			case .BookmarkListDataUpdate:
				return Notification.Name.init("BookmarkListDataUpdate")
			case .newTab:
				return Notification.Name.init("newTab")
			case .newTabsListDataUpdate:
				return Notification.Name.init("newTabsListDataUpdate")
			}
		}
	}
	
	func registerObserver(type: NotiType, vc:UIViewController, selector: Selector) {
		guard let name = type.getNotificationName() else {
			return
		}
		
		//여기에서 노티등록과정을 진행할것.
		NotificationCenter.default.addObserver(vc, selector: selector, name: name, object: nil)
		
	}
	
	func post(type: NotiType, userInfo: [AnyHashable : Any]? = nil) {
		guard let name = type.getNotificationName() else {
			return
		}
		
		NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
	}
	
	func removeAllObserver(vc: UIViewController) {
		NotificationCenter.default.removeObserver(vc)
	}
	
}

