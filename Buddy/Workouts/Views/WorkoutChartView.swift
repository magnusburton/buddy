//
//  WorkoutChartView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-04-29.
//

import SwiftUI

struct WorkoutChartView: View {
	@EnvironmentObject private var workoutManager: WorkoutManager
	
	var workout: WorkoutManager.Workout
	var type: WorkoutManager.DataType
	
	init(workout: WorkoutManager.Workout, for type: WorkoutManager.DataType) {
		self.workout = workout
		self.type = type
	}
	
	var workoutData: WorkoutManager.WorkoutData? {
		if let index = workoutManager.data.firstIndex(where: { workout == $0 }) {
			return workoutManager.data[index].data[type]
		}
		return nil
	}
	
	var body: some View {
		Group {
			if let line = workoutData?.line {
				LineChartView(line: line)
					.chartStyle(LineChartStyle())
			} else {
				EmptyView()
			}
		}
		.frame(height: 150)
	}
}

struct WorkoutChartView_Previews: PreviewProvider {
    static var previews: some View {
		ViewPreview(WorkoutChartView(workout: WorkoutManager.testWorkouts[0], for: .cadence))
			.environmentObject(WorkoutManager())
    }
}
