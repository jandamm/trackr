//
//  GenericFunc.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 28.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation

func match<A, B>
(_ f: @escaping () -> B) ->
	(A) -> B {
	return { _ in
		f()
	}
}
