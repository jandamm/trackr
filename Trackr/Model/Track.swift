//
//  Track.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation
import Overture

struct Track {
	let date: Date
	let location: CLLocationCoordinate2D
	let altitude: Double
	let source: Source
}

extension Track {
	enum Source: String {
		case region, visit, change
	}
}

extension Track: CustomStringConvertible {
	var description: String {
		let dateString = timeFormatter.string(from: date)
		let lon = numberFormatter.string(from: location.longitude as NSNumber)
		let lat = numberFormatter.string(from: location.latitude as NSNumber)
		return "\(dateString): \(lon ?? "nil") - \(lat ?? "")"
	}
}

extension Track: Comparable {
	static func < (lhs: Track, rhs: Track) -> Bool {
		return lhs.date < rhs.date
	}

	static func == (lhs: Track, rhs: Track) -> Bool {
		return lhs.date == rhs.date
	}
}

extension Track {
	typealias Index = Labelled<Date, String>

	func index() -> Index {
		return Index(base: date, convert: { dateFormatter.string(from: $0) })
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

// TODO: nicer composing
let indexLocation = zurry(flip(Track.index))
let groupLocations = reduce(group(by: indexLocation))([Track.Index: [Track]]())

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

func isEqualLocation(_ location1: Track, _ location2: Track) -> Bool {
	guard equal(^\.altitude)(location1, location2) else { return false }
	guard equal(^\.location.longitude)(location1, location2) else { return false }
	guard equal(^\.location.latitude)(location1, location2) else { return false }
	return true
}
