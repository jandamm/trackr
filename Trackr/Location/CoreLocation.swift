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

private let manager = LocationManager()
private let delegate = Location.Delegate()

extension Location {
	static let setupAndStartManager = unzurry(with(manager,
	                                               toVoid(set(\LocationManager.delegate, delegate)),
	                                               toVoid(set(\LocationManager.desiredAccuracy, desiredAccuracy)),
	                                               flurry(LocationManager.requestAlwaysAuthorization),
	                                               flurry(LocationManager.startMonitoringSignificantLocationChanges),
	                                               flurry(LocationManager.startMonitoringVisits)
	))
}

extension Location {
	class Delegate: NSObject, CLLocationManagerDelegate {
		func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
			Location.updateLocations(locations, from: manager)
		}

		func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
			Location.updateVisit(visit, from: manager)
		}

		func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
			Location.updateError(error, from: manager)
		}
	}
}
