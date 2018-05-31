//
//  GenericFunc.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 28.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation

func reduce<Result, A>(_ f: @escaping (Result, A) -> Result) ->
	(_ initialResult: Result) ->
	(_ array: Array<A>) -> Result {
	return { initial in { array in
		array.reduce(initial, f)
	}
	}
}

func reduce<Result, A>(_ f: @escaping (inout Result, A) -> Void) ->
	(_ initialResult: Result) ->
	(_ array: Array<A>) -> Result {
	return { initial in { array in
		array.reduce(into: initial, f)
	}
	}
}

func group<Root, Key: Hashable>(by kp: KeyPath<Root, Key>) ->
	(inout [Key: [Root]], Root) -> Void {
	return { dict, root in
		let key = root[keyPath: kp]
		dict[key, default: [Root]()].append(root)
	}
}

func equal<Root, Value: Equatable>(_ kp: KeyPath<Root, Value>) ->
	(_ lhs: Root, _ rhs: Root) -> Bool {
	return { lhs, rhs in
		lhs[keyPath: kp] == rhs[keyPath: kp]
	}
}

func greater<Root, Value: Comparable>(_ kp: KeyPath<Root, Value>) ->
	(_ lhs: Root, _ rhs: Root) -> Bool {
	return { lhs, rhs in
		lhs[keyPath: kp] > rhs[keyPath: kp]
	}
}

func smaller<Root, Value: Comparable>(_ kp: KeyPath<Root, Value>) ->
	(_ lhs: Root, _ rhs: Root) -> Bool {
	return { lhs, rhs in
		lhs[keyPath: kp] < rhs[keyPath: kp]
	}
}

func map<A, B>(_ f: @escaping (A) -> B) ->
	(Array<A>) -> Array<B> {
	return { $0.map(f) }
}

func map<A, B>(_ f: @escaping (A) -> B) ->
	(Optional<A>) -> Optional<B> {
	return { $0.map(f) }
}

func match<A, B>(_ f: @escaping () -> B) ->
	(A) -> B {
	return { _ in
		f()
	}
}
