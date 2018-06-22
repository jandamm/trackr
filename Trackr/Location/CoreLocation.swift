//
//  CoreLocation.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 10.06.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation
import Overture

typealias LocationManager = CLLocationManager

extension LocationManager {
	private static let manager = LocationManager()
	private static let lmDelegate = Delegate()

	static let setupAndStart = unzurry(with(manager,
	                                        toVoid(set(\LocationManager.delegate, lmDelegate)),
	                                        toVoid(set(\CLLocationManager.desiredAccuracy, Tracking.desiredAccuracy)),
	                                        flurry(LocationManager.requestAlwaysAuthorization),
	                                        flurry(LocationManager.startMonitoringSignificantLocationChanges),
	                                        flurry(LocationManager.startMonitoringVisits)
	))
}

extension LocationManager {
	class Delegate: NSObject, CLLocationManagerDelegate {
		func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
			Tracking.updateLocations(locations, from: manager)
		}

		func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
			Tracking.updateVisit(visit, from: manager)
		}

		func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
			Tracking.updateError(error, from: manager)
		}
	}
}
