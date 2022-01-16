//
//  MaxHeartRate.swift
//  Buddy
//
//  Created by Magnus Burton on 2022-01-11.
//

import Foundation
import HealthKit

struct maxHeartRate {
	let value: Double
	let interval: DateInterval
	let algorithm: HealthTools.MaxHRAlgorithm
	
	private let unit = HKUnit.count().unitDivided(by: .minute())
	
	init(_ quantity: HKQuantity, algorithm: HealthTools.MaxHRAlgorithm, interval: DateInterval) {
		self.value = quantity.doubleValue(for: unit)
		self.interval = interval
		self.algorithm = algorithm
	}
	
	init(_ quantity: HKQuantity, algorithm: HealthTools.MaxHRAlgorithm, start: Date, end: Date) {
		self.value = quantity.doubleValue(for: unit)
		self.interval = DateInterval(start: start, end: end)
		self.algorithm = algorithm
	}
	
	init(_ quantity: HKQuantity, algorithm: HealthTools.MaxHRAlgorithm, date: Date = .now) {
		self.value = quantity.doubleValue(for: unit)
		self.algorithm = algorithm
		
		// 60 days
		self.interval = DateInterval(start: date.addingTimeInterval(-5184000), end: date)
	}
	
	init(_ value: Double, algorithm: HealthTools.MaxHRAlgorithm, interval: DateInterval) {
		self.value = value
		self.interval = interval
		self.algorithm = algorithm
	}
	
	init(_ value: Double, algorithm: HealthTools.MaxHRAlgorithm, start: Date, end: Date) {
		self.value = value
		self.interval = DateInterval(start: start, end: end)
		self.algorithm = algorithm
	}
	
	init(_ value: Double, algorithm: HealthTools.MaxHRAlgorithm, date: Date = .now) {
		self.value = value
		self.algorithm = algorithm
		
		// 60 days
		self.interval = DateInterval(start: date.addingTimeInterval(-5184000), end: date)
	}
	
	lazy var lastReading: Date = {
		self.interval.end
	}()
	
	lazy var quantity: HKQuantity = {
		HKQuantity(unit: unit, doubleValue: self.value)
	}()
	
	var formatted: String {
		self.value.formatted(.number.precision(.fractionLength(1)))
	}
}
