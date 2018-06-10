//
//  LocationDelegate.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 10.06.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation

private let manager = CLLocationManager()
private let delegate = Location.Delegate()

extension Location {
	static let setupAndStartManager = unzurry(with(manager,
	                                               setDelegate(delegate),
	                                               requestAuthorization,
	                                               startMonitoring
	))
}

extension Location {
	class Delegate: NSObject, CLLocationManagerDelegate {
		func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
			Location.updateLocations(locations, from: manager)
		}
	}
}
