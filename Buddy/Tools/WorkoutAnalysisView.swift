//
//  WorkoutAnalysisView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-07-26.
//

import SwiftUI
import CareKitUI

//struct WorkoutAnalysisView: View {
//	@EnvironmentObject private var workoutManager: WorkoutManager
//
//	@ViewBuilder
//	var body: some View {
//		if let total = workoutManager.totalWorkoutsAnalysing {
//			_WorkoutAnalysisView(
//				completed: workoutManager.completedWorkouts,
//				total: total)
//		}
//	}
//}

struct WorkoutAnalysisView: View {
	var completed: Double
	var total: Double
	
	init(_ completed: Int, of total: Int) {
		self.completed = Double(completed)
		self.total = Double(total)
	}
	
	var body: some View {
		CardView {
			VStack(alignment: .leading) {
				Text("workout.analysis.title")
					.font(.headline.bold())
				Text("workout.analysis.description")
					.font(.caption)
					.fontWeight(.medium)
					.lineLimit(nil)
				
				ProgressView(
					value: completed,
					total: total)
//				ProgressBarView(Double(completed), of: Double(total))
				
				Text("\(completed.formatted(.number.precision(.fractionLength(0)))) of \(total.formatted(.number.precision(.fractionLength(0)))) workouts analyzed.")
					.font(.caption)
					.fontWeight(.medium)
					.foregroundColor(.secondary)
			}
			.padding(.all)
		}
	}
}

struct WorkoutAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
		WorkoutAnalysisView(6, of: 26)
    }
}
