//
//  WorkoutDataSample.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-14.
//

import HealthKit

struct HealthSample {
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
		} else {
			return nil
		}
	}
}

extension HealthSample: Identifiable {
	var id: UUID {
		if let sample = quantitySample {
			return sample.uuid
		} else {
			return UUID()
		}
	}
	
	func asPoint(with unit: HKUnit) -> Point {
		Point(quantity: quantity, date: startDate, unit: unit)
	}
}

extension Collection where Element == HealthSample {
	/// Returns an array with the cumulative sum of all elements in the array
	func cumulativeSum(unit: HKUnit) -> [HealthSample] {
		reduce(into: []) {
			let value = ($0.last?.quantity.doubleValue(for: unit) ?? ($0.reserveCapacity(self.count), 0).1) + $1.quantity.doubleValue(for: unit)
			return $0.append(HealthSample(quantity: HKQuantity(unit: unit, doubleValue: value), interval: $1.interval))
		}
	}
    
	/// Returns the sum of all elements in the array
	func sum(unit: HKUnit) -> Double { reduce(.zero) { $0 + $1.quantity.doubleValue(for: unit) } }
	
	/// Returns the average of all elements in the array
	func average(unit: HKUnit) -> Double { isEmpty ? .zero : sum(unit: unit) / Double(count) }
    
	/// Returns the average of all elements in the sequence grouped by an interval
	func average(by interval: Calendar.ComponentInterval, unit: HKUnit) -> [HealthSample] {
		let items = self
		let calendar = Calendar.current
		let components = calendar.getCalendarSet(from: interval)
		
		var average: [HealthSample] = []
		
		let grouped = Dictionary(grouping: items) {
			return calendar.dateComponents(components, from: $0.startDate)
		}
		
		for (_, samples) in grouped {
			if samples.count > 0 {
				let startDate = samples.first!.startDate.startOfDay
				let endDate = startDate.endOfDay
				let interval = DateInterval(start: startDate, end: endDate)
				
				let type = samples.first!.quantityType
				let groupAvg = HKQuantity(unit: unit, doubleValue: samples.average(unit: unit))
				
				let sample = HealthSample(quantity: groupAvg, interval: interval, quantityType: type)
				average.append(sample)
			}
		}
		average.sort(by: { $0.startDate < $1.startDate })
		
		return average
	}
    
	/// Returns the sum of all elements in the sequence grouped by an interval
	func sum(by interval: Calendar.ComponentInterval, unit: HKUnit) -> [HealthSample] {
		let items = self
		let calendar = Calendar.current
		let components = calendar.getCalendarSet(from: interval)
		
		var sum: [HealthSample] = []
		
		let grouped = Dictionary(grouping: items) {
			return calendar.dateComponents(components, from: $0.startDate)
		}
		
		for (_, samples) in grouped {
			if samples.count > 0 {
				let startDate = samples.first!.startDate.startOfDay
				let endDate = startDate.endOfDay
				let interval = DateInterval(start: startDate, end: endDate)
				
				let type = samples.first!.quantityType
				let groupSum = HKQuantity(unit: unit, doubleValue: samples.sum(unit: unit))
				
				let sample = HealthSample(quantity: groupSum, interval: interval, quantityType: type)
				sum.append(sample)
			}
		}
		sum.sort(by: { $0.startDate < $1.startDate })
		
		return sum
	}
	
	func points(unit: HKUnit) -> [Point] {
		map {
            if let sample = $0.quantitySample, sample.count == 1 {
				return Point(sample: sample, unit: unit)
			} else {
				return Point(quantity: $0.quantity, date: $0.endDate, unit: unit)
			}
		}
	}
	
	var last: Self.Element? {
		self[self.count-1 as! Self.Index]
	}
	
	var interval: DateInterval? {
		if let first = self.first, let last = self.last {
			return DateInterval(start: first.startDate, end: last.endDate)
		}
		return nil
	}
    
    /// Returns an array with all elements as a `HKQuantitySample`.
    var asQuantitySamples: [HKQuantitySample] {
        compactMap { sample in
            if let quantitySample = sample.quantitySample {
                return quantitySample
            }
            return nil
        }
    }
}
