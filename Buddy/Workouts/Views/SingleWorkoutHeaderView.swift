//
//  SingleWorkoutHeaderView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-14.
//

import SwiftUI
import HealthKit

struct SingleWorkoutHeaderView: View {
	@EnvironmentObject private var userData: UserData
	
	@State var showMap = false
	
	let workout: HKWorkout
	//	var pace: TimeInterval
	var distance: HKQuantity?
	var duration: TimeInterval
	
	init(workout: HKWorkout) {
		self.workout = workout
		
		distance = workout.totalDistance
		duration = workout.duration
	}
	
	var durationString: String {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .short
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.maximumUnitCount = 2
		
		return formatter.string(from: self.duration) ?? "-"
	}
	
	var dateString: String {
		let formatter = DateFormatter()
		formatter.setLocalizedDateFormatFromTemplate("EEEE, MMMd")
		
		return formatter.string(from: workout.startDate)
	}
	
	var paceString: String {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [.minute, .second]
		formatter.maximumUnitCount = 2
		
		let unit = userData.unitDistance
		let distanceDouble = distance?.doubleValue(for: unit) ?? .leastNonzeroMagnitude
		let pace: TimeInterval = duration / distanceDouble
		
		return formatter.string(from: pace) ?? "-:-"
	}
	
    var body: some View {
		HStack {
			MapView()
				.frame(width: 100, height: 100)
				.cornerRadius(Constants.cornerRadius)
				.onTapGesture {
					showMap = true
				}
				.sheet(isPresented: $showMap, content: {
					//WorkoutMapView(workout: workout, isPresented: self.$showMap)
				})
			
			VStack(alignment: .leading) {
				Text(dateString)
					.font(.caption)
				WorkoutDistanceDetailView(for: distance, unit: userData.unitDistance)
					.font(.title2.bold())
				Text(durationString)
				Text("\(paceString) / \(userData.unitDistance.unitString)")
			}
			
			Spacer()
		}
    }
}

struct SingleWorkoutHeaderView_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			ViewPreview(SingleWorkoutHeaderView(workout: WorkoutManager.testWorkouts[0].workout))
			ViewPreview(SingleWorkoutHeaderView(workout: WorkoutManager.testWorkouts[1].workout))
		}
		.environmentObject(UserData())
    }
}
