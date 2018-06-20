//
//  Location.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 10.06.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation
import Overture

enum Location {
	static let desiredAccuracy: CLLocationAccuracy = 50
}

extension Location {
	static func updateLocations(_ locations: [CLLocation], from locationManager: LocationManager) {
		let validLocations = locations.filter { $0.horizontalAccuracy <= desiredAccuracy }
		guard !validLocations.isEmpty else {
			locationManager.requestLocation()
			return
		}

		let lastTrack = try? SQLiteWrapper.getLastTrack()

		var hasUpdates = false
		validLocations.forEach { location in
			let track = Track(date: location.timestamp, location: location.coordinate, altitude: location.altitude, source: .change)
			guard track != lastTrack else {
				return
			}

			if save(track: track) {
				hasUpdates = true
			}
		}

		guard hasUpdates else { return }
		NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
	}

	static func updateError(_ error: Error, from _: LocationManager) {
		handleError(error)
	}

	// TODO: add nicer storing and validation
	static func updateVisit(_ visit: CLVisit, from _: LocationManager) {
		let unequalTo: (Date) -> (Date) -> Bool = curry(
			!=
		)

		saveVisit(visit, forDate:
			pipe(^\.arrivalDate,
			     validate(unequalTo(Date.distantPast))
			)
		)

		saveVisit(visit, forDate:
			pipe(^\.departureDate,
			     validate(unequalTo(Date.distantFuture))
			)
		)
	}

	private static func saveVisit(_ visit: CLVisit, forDate converter: (CLVisit) -> Date?) {
		guard let date = converter(visit) else { return }
		let track = Track(date: date, location: visit.coordinate, altitude: 0, source: .visit)
		let sameTimeTrack = try? SQLiteWrapper.getTrack(forDate: date)
		guard track != sameTimeTrack else {
			return
		}
		save(track: track)
	}

	private static func handleError(_ error: Error) {
		Defaults.appendError(error)
		sendNotification("Please open Trackr", body: String(describing: error))
	}

	// TODO: refactor!
	@discardableResult private static func save(track: Track) -> Bool {
		do {
			try SQLiteWrapper.add(track)
			return true
		} catch {
			Defaults.appendTrack(track)
			handleError(error)
			return false
		}
	}
}
