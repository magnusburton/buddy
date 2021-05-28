//
//  WorkoutListItemView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-06.
//

import SwiftUI
import HealthKit

struct WorkoutListItemView: View {
	@EnvironmentObject private var userData: UserData
	
	let workout: HKWorkout
//	var pace: TimeInterval
	var distance: HKQuantity?
	var duration: TimeInterval
	var activityType: HKWorkoutActivityType
	
	init(workout: HKWorkout) {
		self.workout = workout
		
		distance = workout.totalDistance
		duration = workout.duration
		activityType = workout.workoutActivityType
	}
	
	var durationString: String {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .short
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.maximumUnitCount = 2
		
		return formatter.string(from: self.duration) ?? "-"
	}
	
	var weekdayString: String {
		let formatter = DateFormatter()
		formatter.setLocalizedDateFormatFromTemplate("EEE")
		
		return formatter.string(from: workout.startDate)
	}
	
	var dateString: String {
		let formatter = DateFormatter()
		formatter.setLocalizedDateFormatFromTemplate("MMMd")
		
		return formatter.string(from: workout.startDate)
	}
	
	var paceString: String {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [.minute, .second]
		formatter.maximumUnitCount = 2
		
		let unit = userData.unitDistance
		let distanceDouble = distance?.doubleValue(for: unit) ?? .leastNonzeroMagnitude
		let pace = duration / distanceDouble
		
		return formatter.string(from: pace) ?? "-:-"
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				VStack(alignment: .center) {
					Text(weekdayString)
					Text(dateString)
						.font(.footnote)
					if activityType == .walking {
						Image(systemName: "figure.walk")
					}
				}
				VStack(alignment: .leading) {
					WorkoutDistanceDetailView(for: distance, unit: userData.unitDistance)
						.font(.title2.bold())
					Text(durationString)
					Text("\(paceString) / \(userData.unitDistance.unitString)")
				}
				.padding(.leading)
				Spacer()
			}
		}
	}
	
	func DistanceDetailView(distance: HKQuantity?, unit: HKUnit) -> Text {
		if distance != nil {
			return Text("\(distance!.doubleValue(for: unit), specifier: "%.2f") \(unit.unitString)")
		} else {
			return Text("-")
		}
	}
}

struct WorkoutListItemView_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			ViewPreview(WorkoutListItemView(workout: WorkoutManager.testWorkouts[0].workout))
			ViewPreview(WorkoutListItemView(workout: WorkoutManager.testWorkouts[1].workout))
		}
		.environmentObject(UserData())
    }
}
