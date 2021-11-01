//
//  HealthKitAverage.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-16.
//

import Foundation
import HealthKit

extension HealthManager.HealthData {
	/// Returns the total sum of all elements in the sequence
	var sum: Double {
		return self.items.sum(unit: self.unit) * self.multiplier
	}
	
	/// Returns the average of all elements in the sequence
	var average: Double {
		return self.items.average(unit: self.unit) * self.multiplier
	}
	
	/// Returns the standard deviation of all elements in the sequence
	var sd: Double {
		let mean = self.average
		
		let sigma = self.items.reduce(0, { $0 + pow($1.quantity.doubleValue(for: self.unit) - mean, 2) })
		let sigmaN = sigma / Double(self.items.count)
		return sqrt(sigmaN)
	}
	
	/// Returns the average of all elements in the sequence grouped by an interval
	func average(by interval: Set<Calendar.Component>) -> [HKQuantitySample] {
		guard let sampleType = HKSampleType.quantityType(forIdentifier: self.identifier) else {
			fatalError("*** Couldn't generate sampleType from \(self.identifier)")
		}
		return self.items.average(by: interval, type: sampleType, unit: self.unit)
	}
	
	/// Returns the average line of all elements in the sequence for the given `lag` days
	func averageLine(by days: Int = Constants.movingAverage) -> Line {
		let moving = self.movingAverage(by: days)
		
		let points = moving.map { Point(sample: $0, unit: self.unit) }
		let line = Line(points: points, label: self.label, multiplier: self.multiplier)
		return line
	}
}
