//
//  HKUnitExtension.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-07-13.
//

import HealthKit

extension HKUnit {
	static let vo2MaxUnit = HKUnit(from: "ml/kg*min")
	
	public var asLengthMeasurement: UnitLength? {
		let lengthQuantity = HKQuantity(unit: .meter(), doubleValue: 1)
		
		guard lengthQuantity.is(compatibleWith: self) else {
			return nil
		}
		
		switch self {
		case .meter():
			return .meters
		case .meterUnit(with: .kilo):
			return .kilometers
		case .inch():
			return .inches
		case .foot():
			return .feet
		case .yard():
			return .yards
		case .mile():
			return .miles
		default:
			return nil
		}
	}
}
