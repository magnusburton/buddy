//
//  HealthKitTrend.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-04-27.
//

import Foundation

extension HealthManager.HealthData {
	/// Trend between last given days of data and the same period before
	func trend(by days: Int = 14) -> Double {
		let calendar = Calendar.current
		let now = Date()
		
		let startCurrent = calendar.date(byAdding: .day, value: -days, to: now) ?? now
		let startPrevious = calendar.date(byAdding: .day, value: -2*days, to: now) ?? now
		
		let currentPeriod = DateInterval(start: startCurrent, end: now)
		let previousPeriod = DateInterval(start: startPrevious, end: startCurrent)
		
		let averages = self.average(by: [.day, .year, .month])
		
		let currentItems = averages.filter { currentPeriod.contains($0.startDate) }
		let previousItems = averages.filter { previousPeriod.contains($0.startDate) }
		
		let currentAverage = currentItems.average(unit: self.unit)
		let previousAverage = previousItems.average(unit: self.unit)
		
		return currentAverage - previousAverage
	}
}
