//
//  Set+Extensions.swift
//  Buddy
//
//  Created by Magnus Burton on 2022-01-10.
//

import Foundation

extension Set {
	
	func toArray<S>(_ of: S.Type) -> [S] {
		self.compactMap({$0 as? S})
	}
	
}

extension NSSet {
	
	func toArray<S>(_ of: S.Type) -> [S] {
		self.compactMap({$0 as? S})
	}
	
}
