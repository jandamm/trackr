//
//  LocationManager.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation

protocol LocationManager: AnyObject {
	var delegate: CLLocationManagerDelegate? { get set }
	func requestAlwaysAuthorization()
	func startMonitoringSignificantLocationChanges()
}

extension CLLocationManager: LocationManager {}

// MARK: - generic base functions

extension Location {
	static func setDelegate(_ delegate: Delegate) ->
		(_ manager: LocationManager) -> Void {
		return { manager in manager.delegate = delegate }
	}

	static func requestAuthorization(_ manager: LocationManager) {
		manager.requestAlwaysAuthorization()
	}

	static func startMonitoring(_ manager: LocationManager) {
		manager.startMonitoringSignificantLocationChanges()
	}
}
