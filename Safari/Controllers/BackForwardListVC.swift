//
//  BackForwardListVC.swift
//  Safari
//
//  Created by 변재우 on 20200224//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class BackForwardListVC: UITableViewController {
	
	var dataSource: [WKBackForwardListItem] = []
	
	override func viewDidLoad() {
		definesPresentationContext = true
		tableView.delegate = self
		tableView.dataSource = self
		
//		self.dataSource = UserDefaultsManager.shared.backList
		registerBackObservers()
		registerForwardObservers()
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BackForwardListCell")
		
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
//		registerObservers()
//		registerBackObservers()
//		registerForwardObservers()
		
//		self.dataSource = UserDefaultsManager.shared.backList
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			self.tableView.reloadData()
		}
		
		
	}
	
	func registerBackObservers() {
		NotificationGroup.shared.registerObserver(type: NotificationGroup.NotiType.backListData, vc: self, selector: #selector(onReceivingBackListData(_:)))
	}
	
	func registerForwardObservers() {
		NotificationGroup.shared.registerObserver(type: NotificationGroup.NotiType.forwardListData, vc: self, selector: #selector(onReceivingForwardListData(_:)))
	}
	
	@objc func onReceivingBackListData(_ notification: Notification) {
//		if let backforwardlistItem = notification.userInfo?["backListStack"] as? WKBackForwardListItem {
////			self.dataSource.append(backforwardlistItem)
//
//		}
		print("notification", notification)
		
		self.dataSource = UserDefaultsManager.shared.backList
		self.tableView.reloadData()
	}
	
	@objc func onReceivingForwardListData(_ notification: Notification) {
//		if let backforwardlistItem = notification.userInfo?["forwardListStack"] as? WKBackForwardListItem {
//			self.dataSource =  [backforwardlistItem]
//		}
		print("notification", notification)
		self.dataSource = UserDefaultsManager.shared.forwardList
		self.tableView.reloadData()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		NotificationGroup.shared.removeAllObserver(vc: self)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BackForwardListCell", for: indexPath)
		cell.textLabel?.text = dataSource[indexPath.row].title
		
		cell.detailTextLabel?.text = dataSource[indexPath.row].url.absoluteString
		
		return cell
	}
	
}

