//
//  CalendarExtension.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-26.
//

import Foundation

extension Calendar {
	func endOfDay(for date: Date) -> Date {
		var start = self.startOfDay(for: date)
		var components = DateComponents()
		components.day = 1
		components.second = -1
		return Calendar.current.date(byAdding: components, to: start)!
	}
}

extension Date {
	var startOfDay: Date {
		return Calendar.current.startOfDay(for: self)
	}
	
	var endOfDay: Date {
		return Calendar.current.endOfDay(for: self)
	}
}
