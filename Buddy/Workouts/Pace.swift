//
//  Pace.swift
//  Buddy
//
//  Created by Magnus Burton on 2022-01-14.
//

import Foundation
import HealthKit

struct Pace {
	
	// MARK: - Properties
	
	let duration: TimeInterval
	let distance: HKQuantity
	
	// MARK: - Initializers
	
	init(duration: TimeInterval, distance: HKQuantity) {
		self.duration = duration
		self.distance = distance
	}
	
	init(interval: DateInterval, distance: HKQuantity) {
		self.duration = interval.duration
		self.distance = distance
	}
	
	init(duration: TimeInterval, sample: HKQuantitySample) {
		self.duration = duration
		self.distance = sample.quantity
	}
	
	init(interval: DateInterval, sample: HKQuantitySample) {
		self.duration = interval.duration
		self.distance = sample.quantity
	}
	
	// MARK: - Public methods
	
	public func formatted(with unit: HKUnit, includeUnit: Bool = true) -> String? {
		let dateCompFormatter = DateComponentsFormatter()
		dateCompFormatter.unitsStyle = .positional
		dateCompFormatter.allowedUnits = [.minute, .second]
		dateCompFormatter.maximumUnitCount = 2
		
		let distanceDouble =  distance.doubleValue(for: unit)
		let pace: TimeInterval = duration / distanceDouble
		
		let unitString = unit == HKUnit.meterUnit(with: .kilo) ? "km" : "mi"
		guard let paceString = dateCompFormatter.string(from: pace) else {
			return nil
		}
		
		if includeUnit {
			return "\(paceString) / \(unitString)"
		} else {
			return paceString
		}
	}
}

extension Pace: Equatable {
	static func == (lhs: Pace, rhs: Pace) -> Bool {
		let paceA = lhs.duration / lhs.distance.doubleValue(for: .meter())
		let paceB = rhs.duration / rhs.distance.doubleValue(for: .meter())
		
		return paceA == paceB
	}
}

extension Pace: Comparable {
	static func < (lhs: Pace, rhs: Pace) -> Bool {
		let paceA = lhs.duration / lhs.distance.doubleValue(for: .meter())
		let paceB = rhs.duration / rhs.distance.doubleValue(for: .meter())
		
		return paceA < paceB
	}
}
