//
//  WorkoutExtension.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-04-27.
//

import HealthKit

extension WorkoutManager.Workout: Equatable {
	
	static func == (lhs: WorkoutManager.Workout, rhs: WorkoutManager.Workout) -> Bool {
		return lhs.workout.uuid == rhs.workout.uuid
	}
}
