//
//  IntervalExtension.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-07-13.
//

import Foundation

extension TimeInterval {
	func format(units: NSCalendar.Unit, style: DateComponentsFormatter.UnitsStyle = .abbreviated, limit: Int = 2) -> String? {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = units
		formatter.unitsStyle = style
		formatter.maximumUnitCount = limit
		
		return formatter.string(from: self)
	}
}

extension DateInterval {
	func format(template: String) -> String {
		let formatter = DateIntervalFormatter()
		formatter.dateTemplate = template
		
		return formatter.string(from: self.start, to: self.end)
	}
}
