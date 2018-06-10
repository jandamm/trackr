//
//  Address.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 10.06.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation

struct Address {
	let street: String
	let houseNumber: String?
	let city: String
	let cityPart: String?
	let country: String
	let region: String?
}

func createAddress(from placemark: CLPlacemark) -> Address? {
	guard let street = placemark.thoroughfare else { return nil }
	guard let city = placemark.locality else { return nil }
	guard let country = placemark.country else { return nil }

	return Address(street: street,
	               houseNumber: placemark.subThoroughfare,
	               city: city,
	               cityPart: placemark.subLocality,
	               country: country,
	               region: placemark.administrativeArea)
}
