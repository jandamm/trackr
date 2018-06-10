//
//  UserDefaultsProtocol.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 10.06.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation

protocol UserDefaultsProtocol {
	func array(forKey key: String) -> [Any]?
	func set(_ value: Any?, forKey key: String)
	func removeObject(forKey key: String)
}

extension UserDefaults: UserDefaultsProtocol {}
