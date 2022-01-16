//
//  RandomAccessCollection.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-26.
//

import Foundation

extension RandomAccessCollection {
	func indexed() -> Array<(offset: Int, element: Element)> {
		Array(enumerated())
	}
}
