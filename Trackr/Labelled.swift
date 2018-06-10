//
//  Index.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 31.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation

struct Labelled<Base, Label> {
	let base: Base
	let label: Label

	init(base: Base, convert: (Base) -> Label) {
		self.base = base
		label = convert(base)
	}
}

extension Labelled: Comparable where Label: Comparable {
	static func < (lhs: Labelled, rhs: Labelled) -> Bool {
		return lhs.label < rhs.label
	}
}

extension Labelled: Equatable where Label: Equatable {
	static func == (lhs: Labelled, rhs: Labelled) -> Bool {
		return lhs.label == rhs.label
	}
}

extension Labelled: Hashable where Label: Hashable {
	var hashValue: Int {
		return label.hashValue
	}
}
