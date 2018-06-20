//
//  Location.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 10.06.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation

enum Location {}

extension Location {
	static func updateLocations(_ locations: [CLLocation], from _: LocationManager) {
		guard locations.count > 0 else { return }

		let lastLocation = try? SQLiteWrapper.getLastLocation()

		var hasUpdates = false
		locations.forEach { clLocation in
			let location = Track(date: clLocation.timestamp, location: clLocation.coordinate, altitude: clLocation.altitude)
			guard !optional(isEqualLocation)(location, lastLocation) else {
				return
			}

			do {
				try SQLiteWrapper.add(location)
				hasUpdates = true
			} catch {
				Defaults.appendError(error)
				Defaults.appendTrack(location)
				sendNotification("Please open Trackr", body: String(describing: error))
			}
		}

		guard hasUpdates else { return }
		NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
	}
}
