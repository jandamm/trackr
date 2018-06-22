//
//  Location.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 10.06.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation
import Overture

enum Tracking {
	static let desiredAccuracy: Double = 100
}

extension Tracking {
	static func updateLocations(_ locations: [Location], from locationManager: LocationManager) {
		guard let lastLocation = locations.last else { return }

		// TODO: nicer filter for slcLocations
		if let slcLocation = lastLocation.speed == -1 ? lastLocation : nil {
			guard slcLocation.timestamp != Defaults.getLastSLCDate() else { return }

			// only save if older than 10 seconds.
			// still not perfect as this also triggers twice per SLC location.
			if slcLocation.timestamp.timeIntervalSinceNow < -10 {
				Defaults.setLastSLCDate(slcLocation.timestamp)
			}
		}

		let validLocations = locations.filter { $0.horizontalAccuracy <= desiredAccuracy }
		guard !validLocations.isEmpty else {
			locationManager.requestLocation()
			return
		}

		let lastTrack = try? SQLiteWrapper.getLastTrack()

		var hasUpdates = false
		validLocations.forEach { location in
			let track = Track(date: location.timestamp, location: location.coordinate, altitude: location.altitude, source: .change)
			guard !optional(isEqualLocation)(track, lastTrack) &&
				!optional(equal(^\Track.date))(track, lastTrack) else {
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
	static func updateVisit(_ visit: Visit, from _: LocationManager) {
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

	private static func saveVisit(_ visit: Visit, forDate converter: (Visit) -> Date?) {
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
