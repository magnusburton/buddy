//
//  CalendarExtension.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-26.
//

import Foundation

extension Calendar {
	func endOfDay(for date: Date) -> Date {
		let start = self.startOfDay(for: date)
		var components = DateComponents()
		components.day = 1
		components.second = -1
		return Calendar.current.date(byAdding: components, to: start)!
	}
	
	func startOfMonth(for date: Date) -> Date {
		return self.date(from: self.dateComponents([.year, .month], from: date))!
	}
	
	func endOfMonth(for date: Date) -> Date {
		return self.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth(for: date))!
	}
}

extension Date {
	var startOfDay: Date {
		return Calendar.current.startOfDay(for: self)
	}
	
	var endOfDay: Date {
		return Calendar.current.endOfDay(for: self)
	}
	
	var yesterday: Date? {
		return Calendar.current.date(byAdding: .day, value: -1, to: self)
	}
	
	var tomorrow: Date? {
		return Calendar.current.date(byAdding: .day, value: +1, to: self)
	}
	
	var startOfMonth: Date {
		return Calendar.current.startOfMonth(for: self)
	}
	
	var endOfMonth: Date {
		return Calendar.current.endOfMonth(for: self)
	}
}
