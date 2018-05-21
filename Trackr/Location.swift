//
//  Location.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation

struct Location {
	let date: Date
	let location: CLLocationCoordinate2D
}

extension Location: CustomStringConvertible {
	var description: String {
		return "\(location.longitude) \(location.latitude)"
	}
}
