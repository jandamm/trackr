//
//  GeoCoder.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 10.06.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Foundation

private let geoCoder = CLGeocoder()

func geoCode(_ location: CLLocation, handler: @escaping (Address) -> Void) {
	geoCoder.reverseGeocodeLocation(location) { placemarks, error in
		guard error == nil else {
			return
		}

		guard let placemark = placemarks?.last,
			let address = createAddress(from: placemark) else { return }
		handler(address)
	}
}
