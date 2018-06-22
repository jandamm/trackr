//
//  Location.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 22.06.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation

typealias Coordinate = CLLocationCoordinate2D

protocol Coordinateable: AnyObject {
	var coordinate: Coordinate { get }
}

protocol Location: Coordinateable {
	var timestamp: Date { get }
	var speed: CLLocationSpeed { get }
	var horizontalAccuracy: CLLocationAccuracy { get }
	var altitude: CLLocationDistance { get }
}

extension CLLocation: Location {}

protocol Visit: Coordinateable {
	var arrivalDate: Date { get }
	var departureDate: Date { get }
}

extension CLVisit: Visit {}
