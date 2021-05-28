//
//  WorkoutDataSample.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-14.
//

import HealthKit

struct WorkoutDataSample {
	var quantity: HKQuantity
	var interval: DateInterval
	var quantityType: HKQuantityType?
	
	var startDate: Date {
		return self.interval.start
	}
	var endDate: Date {
		return self.interval.end
	}
	var duration: TimeInterval {
		return self.interval.duration
	}
	var quantitySample: HKQuantitySample? {
		if let quantityType = self.quantityType {
			return .init(type: quantityType, quantity: self.quantity, start: self.startDate, end: self.endDate)
		}
		
		return nil
	}
}

extension Collection where Element == WorkoutDataSample {
	/// Returns the sum of all elements in the array
	func sum(unit: HKUnit) -> Double { reduce(.zero) { $0 + $1.quantity.doubleValue(for: unit) } }
	/// Returns the average of all elements in the array
	func average(unit: HKUnit) -> Double { isEmpty ? .zero : sum(unit: unit) / Double(count) }
}
