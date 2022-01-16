//
//  HKActivitySummaryExtensions.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-04-26.
//

import HealthKit

@available(watchOS 2.2, *)
public extension HKActivitySummary {
	/// Check if stand goal is met.
	var isStandGoalMet: Bool { appleStandHoursGoal.compare(appleStandHours) != .orderedDescending }
	
	/// Check if exercise time goal is met.
	var isExerciseTimeGoalMet: Bool { appleExerciseTimeGoal.compare(appleExerciseTime) != .orderedDescending }
	
	/// Check if active energy goal is met.
	var isEnergyBurnedGoalMet: Bool { activeEnergyBurnedGoal.compare(activeEnergyBurned) != .orderedDescending }
}
