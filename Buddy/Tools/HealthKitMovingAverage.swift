//
//  HealthKitMovingAverage.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-29.
//

import Foundation
import HealthKit

extension HealthManager.HealthData {
	/// Returns the daily moving average of all elements in the sequence calculated with a date lag
	func movingAverage(by lag: Int) -> [HKQuantitySample] {
		let calendar = Calendar.current
		let sampleType = HKSampleType.quantityType(forIdentifier: self.identifier)
		
		let array = self.average(by: [.day, .year, .month])
		let count = array.count
		
		return (0..<count).compactMap { index in
			if (0..<lag).contains(index) { return nil }
			let range = index - lag..<index
			let sum = array[range].reduce(.zero) { $0 + $1.quantity.doubleValue(for: unit) }
			let result: Double = sum / Double(lag)

			let endDate = calendar.startOfDay(for: array[range].last!.endDate)
			let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) ?? endDate
			let groupAvg = HKQuantity(unit: self.unit, doubleValue: result)

			return .init(type: sampleType!, quantity: groupAvg, start: startDate, end: endDate)
		}
	}
}
