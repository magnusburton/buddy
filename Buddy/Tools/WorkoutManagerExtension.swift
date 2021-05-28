//
//  WorkoutManagerExtension.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-04-29.
//

import Foundation
import HealthKit

extension WorkoutManager.WorkoutData {
	/// Returns the total sum of all elements in the sequence
	var sum: Double {
		return self.items.sum(unit: self.unit)
	}
	
	/// Returns the average of all elements in the sequence
	var average: Double {
		return self.items.average(unit: self.unit)
	}
}
