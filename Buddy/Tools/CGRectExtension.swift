//
//  CGRectExtension.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-07-01.
//

import SwiftUI

extension CGRect {
	func getClosestPointOnEdge(to point: CGPoint) -> CGPoint {
		var x = point.x
		var y = point.y
		
		if point.x < self.minX {
			x = self.minX
		} else if point.x > self.maxX {
			x = self.maxX
		}
		
		if point.y < self.minY {
			y = self.minY
		} else if point.y > self.maxY {
			y = self.maxY
		}
		
		return CGPoint(x: x, y: y)
	}
}
