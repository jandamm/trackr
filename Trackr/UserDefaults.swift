//
//  UserDefaults.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 26.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation

private let errors: Defaults.Store = (.standard, "errors")
private let locations: Defaults.Store = (.standard, "locations")

struct Defaults {
	typealias Store = (ud: UserDefaults, key: String)
	static func getValues<T>
	(from store: Store) ->
		() -> [T] {
		return {
			guard let array = store.ud.array(forKey: store.key) as? [T] else { return [] }
			return array
		}
	}

	static func appendValue<T>
	(in store: Store) ->
		(_ value: T) -> Void {
		return { value in
			var values: [T] = getValues(from: store)()
			values.append(value)
			store.ud.set(values, forKey: store.key)
		}
	}

	static func deleteValues
	(from store: Store) ->
		() -> Void {
		return {
			store.ud.removeObject(forKey: store.key)
		}
	}

	static let getLocations: () -> [Location] = getValues(from: locations)
	static let getErrors: () -> [Error] = getValues(from: errors)

	static let appendLocation: (Location) -> Void = appendValue(in: locations)
	static let appendError: (Error) -> Void = appendValue(in: errors)

	static let deleteLocations: () -> Void = deleteValues(from: locations)
	static let deleteErrors: () -> Void = deleteValues(from: errors)
}
