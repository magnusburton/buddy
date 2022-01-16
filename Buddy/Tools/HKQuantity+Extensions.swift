//
//  HealthKitMeasurementConversion.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-10-21.
//

import Foundation
import HealthKit

extension HKQuantity {
	
	var asMeasurement: Measurement<UnitLength>? {
		guard self.is(compatibleWith: .meter()) else {
			return nil
		}
		
		let value = self.doubleValue(for: .meter())
		return Measurement(value: value, unit: .meters)
	}
}
