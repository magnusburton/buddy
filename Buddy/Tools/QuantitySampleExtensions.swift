//
//  QuantitySampleExtensions.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-29.
//

import Foundation
import HealthKit

extension Collection where Element: HKQuantitySample {
	/// Returns the sum of all elements in the array
	func sum(unit: HKUnit) -> Double { reduce(.zero) { $0 + $1.quantity.doubleValue(for: unit) } }
	/// Returns the average of all elements in the array
	func average(unit: HKUnit) -> Double { isEmpty ? .zero : sum(unit: unit) / Double(count) }
	/// Returns the average of all elements in the sequence grouped by an interval
	func average(by interval: Set<Calendar.Component>, type: HKQuantityType, unit: HKUnit) -> [HKQuantitySample] {
		let items = self
		let calendar = Calendar.current
		
		var average: [HKQuantitySample] = []
		
		let grouped = Dictionary(grouping: items) {
			return calendar.dateComponents(interval, from: $0.startDate)
		}
		
		for (_, samples) in grouped {
			if samples.count > 0 {
				let startDate = calendar.startOfDay(for: samples.first!.startDate)
				let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
				let groupAvg = HKQuantity(unit: unit, doubleValue: samples.average(unit: unit))
				
				let sample = HKQuantitySample(type: type, quantity: groupAvg, start: startDate, end: endDate)
				average.append(sample)
			}
		}
		
		average.sort(by: { $0.startDate < $1.startDate })
		
		return average
	}
}

extension HKQuantitySample {
	var workoutDataSample: WorkoutDataSample {
		let interval = DateInterval(start: self.startDate, end: self.endDate)
		return .init(quantity: self.quantity, interval: interval, quantityType: self.quantityType)
	}
}
