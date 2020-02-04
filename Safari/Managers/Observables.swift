//
//  Observables.swift
//  Safari
//
//  Created by 변재우 on 20200204//.
//  Copyright © 2020 변재우. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class Observables {
	static let shared = Observables()
	
	var delegate: Observables?
	
	var currentContentMode: WKWebpagePreferences.ContentMode?
	var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
	var estimatedProgressObservationToken: NSKeyValueObservation?
	var canGoBackObservationToken: NSKeyValueObservation?
	var canGoForwardObservationToken: NSKeyValueObservation?
	
	
}
