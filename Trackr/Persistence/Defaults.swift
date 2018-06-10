//
//  UserDefaults.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 26.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation

enum Defaults {
	case errors, locations
}

extension Defaults {
	typealias Storage = (storage: UserDefaultsProtocol, key: String)

	var store: Storage {
		switch self {
		case .errors:
			return (UserDefaults.standard, "errors")
		case .locations:
			return (UserDefaults.standard, "locations")
		}
	}
}

// MARK: - specific getters

extension Defaults {
	static let getLocations: () -> [Track] = getValues(from: Defaults.locations.store)
	static let getErrors: () -> [Error] = getValues(from: Defaults.errors.store)

	static let appendLocation: (Track) -> Void = appendValue(in: Defaults.locations.store)
	static let appendError: (Error) -> Void = appendValue(in: Defaults.errors.store)

	static let deleteLocations: () -> Void = deleteValues(from: Defaults.locations.store)
	static let deleteErrors: () -> Void = deleteValues(from: Defaults.errors.store)
}

// MARK: - generic functions

extension Defaults {
	static func getValues<T>(from store: Storage) ->
		() -> [T] {
		return {
			guard let array = store.storage.array(forKey: store.key) as? [T] else { return [] }
			return array
		}
	}

	static func appendValue<T>(in store: Storage) ->
		(_ value: T) -> Void {
		return { value in
			var values: [T] = getValues(from: store)()
			values.append(value)
			store.storage.set(values, forKey: store.key)
		}
	}

	static func deleteValues(from store: Storage) ->
		() -> Void {
		return {
			store.storage.removeObject(forKey: store.key)
		}
	}
}
