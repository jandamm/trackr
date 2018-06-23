//
//  UserDefaults.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 26.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation

enum Defaults {
	case errors, tracks
}

extension Defaults {
	typealias Storage = (storage: UserDefaultsProtocol, key: String)

	var store: Storage {
		switch self {
		case .errors:
			return (UserDefaults.standard, "errors")
		case .tracks:
			return (UserDefaults.standard, "tracks")
		}
	}
}

// MARK: - specific getters

extension Defaults {
	static let getTracks: () -> [Track] = getValues(from: Defaults.tracks.store)
	static let getErrors: () -> [Error] = getValues(from: Defaults.errors.store)

	static let appendTrack: (Track) -> Void = appendValue(in: Defaults.tracks.store)
	static let appendError: (Error) -> Void = appendValue(in: Defaults.errors.store)

	static let deleteTracks: () -> Void = deleteValues(from: Defaults.tracks.store)
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

	static func getValue<T>(from store: Storage) ->
		() -> T? {
		return {
			store.storage.object(forKey: store.key) as? T
		}
	}

	static func setValue<T>(in store: Storage) ->
		(_ value: T) -> Void {
		return { value in
			store.storage.set(value, forKey: store.key)
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
