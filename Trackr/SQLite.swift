//
//  SQLite.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import SQLite

class SQLiteWrapper {
	private static var db: Connection!
	private static var location: Table!

	static let date = Expression<Double>("date")
	static let lon = Expression<Double>("lon")
	static let lat = Expression<Double>("lat")

	static func setup() throws {
		let path = NSSearchPathForDirectoriesInDomains(
			.documentDirectory, .userDomainMask, true
		).first!
		db = try Connection("\(path)/db.sqlite3")

		location = Table("location")

		try db.run(location.create(ifNotExists: true) { t in
			t.column(date, unique: true)
			t.column(lon)
			t.column(lat)
		})
	}

	static func add(_ l: Location) throws {
		let insert = location.insert(date <- l.date.timeIntervalSince1970, lon <- l.location.longitude, lat <- l.location.latitude)
		_ = try db.run(insert)
	}

	static func getLocations() throws -> [Location] {
		return try db.prepare(location).map { row in
			let date = row[self.date]
			let lon = row[self.lon]
			let lat = row[self.lat]
			return Location(date: Date(timeIntervalSince1970: date),
			                location: CLLocationCoordinate2D(latitude: lat, longitude: lon)
			)
		}
	}
}
