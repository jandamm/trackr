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
		let dateString = timeFormatter.string(from: date)
		let lon = numberFormatter.string(from: location.longitude as NSNumber)
		let lat = numberFormatter.string(from: location.latitude as NSNumber)
		return "\(dateString): \(lon ?? "nil") - \(lat ?? "")"
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

extension Location {
	struct Index {
		let date: Date
		let label: String

		init(date: Date) {
			self.date = date
			label = dateFormatter.string(from: date)
		}
	}

	var index: Index {
		return Index(date: date)
	}
}

extension Location.Index: Comparable {
	static func < (lhs: Location.Index, rhs: Location.Index) -> Bool {
		return lhs.label < rhs.label
	}

	static func == (lhs: Location.Index, rhs: Location.Index) -> Bool {
		return lhs.label == rhs.label
	}
}

extension Location.Index: Hashable {
	var hashValue: Int {
		return label.hashValue
	}
}

private let dateFormatter = { () -> DateFormatter in
	let dateFormatter = DateFormatter()
	dateFormatter.dateStyle = .short
	dateFormatter.timeStyle = .none
	return dateFormatter
}()

private let timeFormatter = { () -> DateFormatter in
	let dateFormatter = DateFormatter()
	dateFormatter.dateStyle = .none
	dateFormatter.timeStyle = .short
	return dateFormatter
}()

private let numberFormatter = { () -> NumberFormatter in
	let numberFormatter = NumberFormatter()
	numberFormatter.maximumFractionDigits = 5
	return numberFormatter
}()

let groupLocations = reduce(group(by: \Location.index))([Location.Index: [Location]]())

func optional<A>(_ f: @escaping (A, A) -> Bool) ->
	(A?, A?) -> Bool {
	return { a1, a2 in
		switch (a1, a2) {
		case let (a1?, a2?):
			return f(a1, a2)
		default:
			return false
		}
	}
}

func isEqualLocation(_ location1: Location, _ location2: Location) -> Bool {
	guard equal(\.altitude)(location1, location2) else { return false }
	guard equal(\.location.longitude)(location1, location2) else { return false }
	guard equal(\.location.latitude)(location1, location2) else { return false }
	return true
}
