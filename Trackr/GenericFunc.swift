//
//  GenericFunc.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 28.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation

func map<A, B> (_ f: @escaping (A) -> B) ->
	(Array<A>) -> Array<B> {
	return { $0.map(f) }
}

func map<A, B> (_ f: @escaping (A) -> B) ->
	(Optional<A>) -> Optional<B> {
	return { $0.map(f) }
}

func match<A, B> (_ f: @escaping () -> B) ->
(_ f: @escaping () -> B) ->
	(A) -> B {
	return { _ in
		f()
	}
}
