//
//  GenericFunc.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 28.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation
import Overture

func with<A: NSObject>(_ a: A, _ fs: ((A) -> Void)...) {
	fs.forEach { f in f(a) }
}

func unzurry<A>(_ a: A) -> () -> A {
	return { a }
}

func validate<A>(_ f: @escaping (A) -> Bool) -> (A) -> A? {
	return { a in
		f(a) ? a : nil
	}
}

func flurry<A, B>(_ f: @escaping (A) -> () -> B) -> (A) -> B {
	return zurry(flip(f))
}

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

func group<Root, Key: Hashable>(by f: @escaping (Root) -> Key) ->
	(inout [Key: [Root]], Root) -> Void {
	return { dict, root in
		let key = f(root)
		dict[key, default: [Root]()].append(root)
	}
}

func equal<Root, Value: Equatable>(_ f: @escaping (Root) -> Value) ->
	(_ lhs: Root, _ rhs: Root) -> Bool {
	return { lhs, rhs in
		f(lhs) == f(rhs)
	}
}

func greater<Root, Value: Comparable>(_ f: @escaping (Root) -> Value) ->
	(_ lhs: Root, _ rhs: Root) -> Bool {
	return { lhs, rhs in
		f(lhs) > f(rhs)
	}
}

func smaller<Root, Value: Comparable>(_ f: @escaping (Root) -> Value) ->
	(_ lhs: Root, _ rhs: Root) -> Bool {
	return { lhs, rhs in
		f(lhs) < f(rhs)
	}
}

func match<A, B>(_ f: @escaping () -> B) ->
	(A) -> B {
	return { _ in
		f()
	}
}

func toVoid<A, B>(_ f: @escaping (A) -> B) ->
	(A) -> Void {
	return { a in
		_ = f(a)
	}
}

func toOptional<A>(_ f: @escaping (A) -> Bool) ->
	(A) -> A? {
	return { a in f(a) ? a : nil }
}

func toBool<A>(_ f: @escaping (A) -> A?) ->
	(A) -> Bool {
	return { a in f(a) != nil }
}
