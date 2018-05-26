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
	static let alt = Expression<Double>("alt")

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
			t.column(alt)
		})
	}

	static func add(_ l: Location) throws {
		let insert = location.insert(date <- l.date.timeIntervalSince1970, lon <- l.location.longitude, lat <- l.location.latitude, alt <- l.altitude)
		_ = try db.run(insert)
	}

	static func remove(_ l: Location) throws {
		let entry = location.filter(date == l.date.timeIntervalSince1970)
		try db.run(entry.delete())
	}

	static func getLastLocation() throws -> Location {
		let filteredTable = location.order(date.desc)
			.limit(1)
		let rowList = try db.prepare(filteredTable).map(rowMapper)

		guard let firstEntry = rowList.first else {
			throw SQLError("No Entry")
		}
		return firstEntry
	}

	static func getLocations() throws -> [Location] {
		return try db.prepare(location).map(rowMapper)
	}
}

private func rowMapper(_ row: Row) -> Location {
	let date = row[SQLiteWrapper.date]
	let lon = row[SQLiteWrapper.lon]
	let lat = row[SQLiteWrapper.lat]
	let alt = row[SQLiteWrapper.alt]
	return Location(date: Date(timeIntervalSince1970: date),
	                location: CLLocationCoordinate2D(latitude: lat, longitude: lon),
	                altitude: alt
	)
}

func addColumn<T: Value>(column: Expression<T?>, to database: Connection, in table: Table) throws {
	do {
		try database.run(table.addColumn(column))
	} catch {
		guard case let SQLite.Result.error(message, code, _) = error,
			code == 1
		else { throw error }
		print(message)
	}
}

struct SQLError: Error, CustomStringConvertible {
	let description: String

	init(_ description: String) {
		self.description = description
	}
}
