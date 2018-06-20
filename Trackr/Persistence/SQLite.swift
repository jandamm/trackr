//
//  SQLite.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Overture
import SQLite

class SQLiteWrapper {
	private static var db: Connection!
	private static var location: Table!

	static let dat = Expression<Double>("date")
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
			t.column(dat, unique: true)
			t.column(lon)
			t.column(lat)
			t.column(alt)
		})
	}

	static func add(_ t: Track) throws {
		let insert = location.insert(dat <- t.date.timeIntervalSince1970, lon <- t.location.longitude, lat <- t.location.latitude, alt <- t.altitude)
		_ = try db.run(insert)
	}

	static func remove(_ t: Track) throws {
		let entry = location.filter(dat == t.date.timeIntervalSince1970)
		try db.run(entry.delete())
	}

	static func getLastTrack() throws -> Track {
		return try with(
			location
				.order(dat.desc)
				.limit(1),
			getFirstTrackOfTable
		)
	}

	static func getTrack(forDate date: Date) throws -> Track {
		return try with(
			location
				.filter(dat == date.timeIntervalSince1970),
			getFirstTrackOfTable
		)
	}

	private static let getFirstTrackOfTable = pipe(getTracksOf, getFirstTrack)

	private static func getTracksOf(_ table: Table) throws -> [Track] {
		return try db.prepare(table).map(rowMapper)
	}

	private static func getFirstTrack(of tracks: [Track]) throws -> Track {
		guard let firstEntry = tracks.first else {
			throw SQLError("No Entry")
		}
		return firstEntry
	}

	static func getLocations() throws -> [Track] {
		return try db.prepare(location).map(rowMapper)
	}
}

private func rowMapper(_ row: Row) -> Track {
	let date = row[SQLiteWrapper.dat]
	let lon = row[SQLiteWrapper.lon]
	let lat = row[SQLiteWrapper.lat]
	let alt = row[SQLiteWrapper.alt]
	return Track(date: Date(timeIntervalSince1970: date),
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
