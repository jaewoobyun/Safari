//
//  NavigationVC.swift
//  Safari
//
//  Created by 변재우 on 20200128//.
//  Copyright © 2020 변재우. All rights reserved.
//

import UIKit

class NavigationVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		print("navigation bar frame!!!!!!")
		print(self.navigationBar.frame)
		print("searchbar frame!!!!!!!!!!!!")
		print(self.navigationItem.searchController?.searchBar.frame)
		self.navigationBar.frame = CGRect(x: 0.0, y: -22.0, width: 375.0, height: 22.0)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
