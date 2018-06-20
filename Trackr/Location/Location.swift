//
//  Location.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 10.06.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation

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
			let track = Track(date: location.timestamp, location: location.coordinate, altitude: location.altitude)
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

	// TODO: add nicer storing and validation
	static func updateVisit(_ visit: CLVisit, from _: LocationManager) {
		let track = Track(date: visit.arrivalDate, location: visit.coordinate, altitude: 0)
		save(track: track)
	}

	// TODO: refactor!
	@discardableResult private static func save(track: Track) -> Bool {
		do {
			try SQLiteWrapper.add(track)
			return true
		} catch {
			Defaults.appendError(error)
			Defaults.appendTrack(track)
			sendNotification("Please open Trackr", body: String(describing: error))
			return false
		}
	}
}
