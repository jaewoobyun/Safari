//
//  HistoryNavigationController.swift
//  Safari
//
//  Created by 변재우 on 20200224//.
//  Copyright © 2020 변재우. All rights reserved.
//

import UIKit

class HistoryNavigationController: UINavigationController {
	
	var entryPoint = entryPointType.history //by default
	
	enum entryPointType {
		case backList
		case forwardList
		case history
	}
	
	//	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
	//		<#code#>
	//	}
	//
	//	required init?(coder aDecoder: NSCoder) {
	//		fatalError("init(coder:) has not been implemented")
	//	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		definesPresentationContext = true
		
		// Do any additional setup after loading the view.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		switch self.entryPoint {
		case .backList:
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let backVC = storyboard.instantiateViewController(identifier: "BackForwardListVC") as BackForwardListVC
			//			let backVC = storyboard?.instantiateViewController(withIdentifier: "BackForwardListVC") //as! BackForwardListVC
			backVC.title = "Back List"
			//						backVC.registerBackObservers()
			//			self.pushViewController(backVC!, animated: true)
			backVC.dataSource = UserDefaultsManager.shared.backList
			
			self.show(backVC, sender: nil)
			//			self.present(backVC, animated: true, completion: nil)
			
		case .forwardList:
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let forwardVC = storyboard.instantiateViewController(withIdentifier: "BackForwardListVC") as! BackForwardListVC
			forwardVC.title = "Forward List"
			//			forwardVC.registerForwardObservers()
			//			self.pushViewController(forwardVC!, animated: true)
			
			forwardVC.dataSource = UserDefaultsManager.shared.forwardList
			self.show(forwardVC, sender: nil)
			//			self.present(forwardVC!, animated: true, completion: nil)
			
		default:
			let historyVC = storyboard?.instantiateViewController(withIdentifier: "HistoryVC")
			//			self.pushViewController(historyVC!, animated: true)
			//			self.show(historyVC!, sender: nil)
			self.present(historyVC!, animated: true, completion: nil)
		}
	}
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	//	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	//	// Get the new view controller using segue.destination.
	//	// Pass the selected object to the new view controller.
	//		print("whatttt?")
	//	}
	
	
}
