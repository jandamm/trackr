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
	let altitude: Double
}

extension Location: CustomStringConvertible {
	var description: String {
		let dateString = dateFormatter.string(from: date)
		return "\(dateString): \(location.longitude) - \(location.latitude)"
	}
}

extension Location: Comparable {
	static func < (lhs: Location, rhs: Location) -> Bool {
		return lhs.date < rhs.date
	}

	static func == (lhs: Location, rhs: Location) -> Bool {
		return lhs.date == rhs.date
	}
}

private let dateFormatter = { () -> DateFormatter in
	let dateFormatter = DateFormatter()
	dateFormatter.dateStyle = .short
	dateFormatter.timeStyle = .short
	return dateFormatter
}()
