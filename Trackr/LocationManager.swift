//
//  LocationManager.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate {
	static let shared = LocationManager()
	let locationManager: CLLocationManager

	override init() {
		locationManager = CLLocationManager()
		super.init()

		locationManager.delegate = self
	}

	func start() {
		locationManager.requestAlwaysAuthorization()
		locationManager.startMonitoringSignificantLocationChanges()
	}

	func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard locations.count > 0 else { return }

		let lastLocation = try? SQLiteWrapper.getLastLocation()

		var hasUpdates = false
		locations.forEach { clLocation in
			let location = Location(date: clLocation.timestamp, location: clLocation.coordinate, altitude: clLocation.altitude)
			guard !optional(isEqualLocation)(location, lastLocation) else {
				return
			}

			do {
				try SQLiteWrapper.add(location)
				hasUpdates = true
			} catch {
				Defaults.appendError(error)
				Defaults.appendLocation(location)
				sendNotification("Please open Trackr", body: String(describing: error))
			}
		}

		guard hasUpdates else { return }
		NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
	}
}
