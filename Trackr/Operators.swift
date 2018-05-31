//
//  Operators.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 31.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation
import Overture

prefix operator ^

prefix func ^ <Root, Value>(rhs: KeyPath<Root, Value>) ->
	(Root) -> Value {
	return get(rhs)
}
