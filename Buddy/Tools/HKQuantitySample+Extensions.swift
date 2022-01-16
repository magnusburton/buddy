//
//  QuantitySampleExtensions.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-29.
//

import Foundation
import HealthKit

extension HKQuantitySample {
    var asHealthSample: HealthSample {
		HealthSample(quantity: self.quantity, interval: self.interval, quantityType: self.quantityType)
    }
    
    var interval: DateInterval {
        DateInterval(start: self.startDate, end: self.endDate)
    }
    
    func asPoint(unit: HKUnit) -> Point {
        Point(sample: self, unit: unit)
    }
    
    var duration: TimeInterval {
		self.interval.duration
    }
}

extension Collection where Element: HKQuantitySample {
	/// Returns the sum of all elements in the array
	func sum(unit: HKUnit) -> Double { reduce(.zero) { $0 + $1.quantity.doubleValue(for: unit) } }
    
	/// Returns the average of all elements in the array
	func average(unit: HKUnit) -> Double { isEmpty ? .zero : sum(unit: unit) / Double(count) }
    
	/// Returns the average of all elements in the sequence grouped by an interval
	func average(by interval: Calendar.ComponentInterval, type: HKQuantityType, unit: HKUnit) -> [HKQuantitySample] {
		let items = self
        let calendar = Calendar.current
        let components = calendar.getCalendarSet(from: interval)
		
		var average: [HKQuantitySample] = []
		
		let grouped = Dictionary(grouping: items) {
			return calendar.dateComponents(components, from: $0.startDate)
		}
		
		for (_, samples) in grouped {
			if samples.count > 0 {
				let startDate = samples.first!.startDate.startOfDay
				let endDate = startDate.endOfDay 
				let groupAvg = HKQuantity(unit: unit, doubleValue: samples.average(unit: unit))
				
				let sample = HKQuantitySample(type: type, quantity: groupAvg, start: startDate, end: endDate)
				average.append(sample)
			}
		}
		average.sort(by: { $0.startDate < $1.startDate })
		
		return average
	}
    
	/// Returns the sum of all elements in the sequence grouped by an interval
	func sum(by interval: Calendar.ComponentInterval, type: HKQuantityType, unit: HKUnit) -> [HKQuantitySample] {
		let items = self
        let calendar = Calendar.current
        let components = calendar.getCalendarSet(from: interval)
		
		var sum: [HKQuantitySample] = []
		
		let grouped = Dictionary(grouping: items) {
			return calendar.dateComponents(components, from: $0.startDate)
		}
		
		for (_, samples) in grouped {
			if samples.count > 0 {
				let startDate = samples.first!.startDate.startOfDay
				let endDate = startDate.endOfDay
				let groupSum = HKQuantity(unit: unit, doubleValue: samples.sum(unit: unit))
				
				let sample = HKQuantitySample(type: type, quantity: groupSum, start: startDate, end: endDate)
				sum.append(sample)
			}
		}
		sum.sort(by: { $0.startDate < $1.startDate })
		
		return sum
	}
    
	/// Returns an array with the cumulative sum of all elements in the array
	func cumulativeSum(unit: HKUnit) -> [HealthSample] {
		reduce(into: []) {
			let value = ($0.last?.quantity.doubleValue(for: unit) ?? ($0.reserveCapacity(self.count), 0).1) + $1.quantity.doubleValue(for: unit)
			return $0.append(HealthSample(quantity: HKQuantity(unit: unit, doubleValue: value), interval: $1.interval))
		}
	}
    
	/// Returns an array with all elements as a `HealthSample`.
	var asHealthSamples: [HealthSample] {
		map { $0.asHealthSample }
	}
}
