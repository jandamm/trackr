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
		guard let location = locations.last else { return }
		let loc = Location(date: Date(), location: location.coordinate, altitude: location.altitude)
		do {
			try SQLiteWrapper.add(loc)
			NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
		} catch {
			print(error)
			// TODO: alternative saving method
		}
	}
}
