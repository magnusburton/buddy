//
//  WorkoutView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-05.
//

import SwiftUI
import HealthKit
import CareKitUI

struct WorkoutView: View {
	@EnvironmentObject private var userData: UserData
	@EnvironmentObject private var workoutManager: WorkoutManager
	
    var body: some View {
		NavigationView {
			listView
			.navigationBarTitle(Text("Workouts"))
		}
    }
	
	@ViewBuilder
	var listView: some View {
		if workoutManager.data.isEmpty {
			emptyListView
		} else {
			objectsListView
		}
	}
	
	var emptyListView: some View {
		VStack {
			Text("🐾")
				.font(.system(size: 45))
			Text("No data found.")
			Text("Make sure you've granted Buddy permission\nto read your recent workouts.")
				.font(.caption)
				.foregroundColor(.gray)
				.multilineTextAlignment(.center)
		}
	}
	
	var objectsListView: some View {
		List(workoutManager.data.filter { workout in
			if !userData.includeWalks && workout.type == .walking {
				return false
			}
			return true
		}) { workout in
			NavigationLink(destination: SingleWorkoutView(workout: workout)) {
				WorkoutListItemView(workout: workout.workout)
			}
		}
	}
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
		let workoutManager = WorkoutManager()
		workoutManager.data = WorkoutManager.testWorkouts
		
		return Group {
			WorkoutView()
				.environmentObject(workoutManager)
			WorkoutView()
				.environmentObject(WorkoutManager())
			
			WorkoutView()
				.background(Color(.systemBackground))
				.environment(\.colorScheme, .dark)
				.environmentObject(workoutManager)
			WorkoutView()
				.background(Color(.systemBackground))
				.environment(\.colorScheme, .dark)
				.environmentObject(WorkoutManager())
		}
		.environmentObject(UserData())
    }
}
