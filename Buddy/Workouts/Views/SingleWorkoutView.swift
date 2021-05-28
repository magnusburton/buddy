//
//  SingleWorkoutView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-14.
//

import SwiftUI
import HealthKit
import CareKitUI

struct SingleWorkoutView: View {
	@EnvironmentObject private var userData: UserData
	@EnvironmentObject private var workoutManager: WorkoutManager
	
	let workout: WorkoutManager.Workout
	
	var workoutData: WorkoutManager.Workout? {
		if let index = workoutManager.data.firstIndex(where: { workout == $0 }) {
			return workoutManager.data[index]
		}
		return nil
	}
	
	var body: some View {
		VStack {
			SingleWorkoutHeaderView(workout: workout.workout)
				.padding([.top, .leading, .trailing])
			
			ScrollView {
				LazyVStack {
					CardView {
						VStack {
							LabeledValueTaskView(
								title: Text("Cadence"),
								detail: Text("During the past two months your average HRV has increased. This is a good sign and represent an increase in fitness and a decreased level of stress."),
								state: .complete(
									Text("\(workoutData?.data[.cadence]?.average ?? 0, specifier: "%.0f")"),
									Text("spm")
								)
							)
							
							Divider()
							
							WorkoutChartView(workout: self.workout, for: .cadence)
						}
						.padding()
					}
					
					CardView {
						VStack {
							LabeledValueTaskView(
								title: Text("Distance"),
								detail: Text("During the past two months your average HRV has increased. This is a good sign and represent an increase in fitness and a decreased level of stress."),
								state: .complete(
									Text("\(self.workout.data[.distance]?.average ?? 0, specifier: "%.0f")"),
									Text("spm")
								)
							)
							
							Divider()
							
							WorkoutChartView(workout: self.workout, for: .distance)
						}
						.padding()
					}
					
					CardView {
						VStack {
							LabeledValueTaskView(
								title: Text("Heart Rate"),
								detail: Text("During the past two months your average HRV has increased. This is a good sign and represent an increase in fitness and a decreased level of stress."),
								state: .complete(
									Text("\(self.workout.data[.heartrate]?.average ?? 0, specifier: "%.0f")"),
									Text("spm")
								)
							)
							
							Divider()
							
							WorkoutChartView(workout: self.workout, for: .heartrate)
						}
						.padding()
					}
				}
				.padding([.leading, .bottom, .trailing])
			}
		}
		.onAppear(perform: {
			workoutManager.getWorkoutData(for: workout, identifier: .distanceWalkingRunning) { samples, error in
				guard error == nil else {
					// Handle any errors
					return
				}
				workoutManager.generateWorkoutData(for: workout, of: .pace, with: samples ?? [])
				
				workoutManager.generateWorkoutData(for: workout, of: .distance, with: samples ?? [])
				
			}
			workoutManager.getWorkoutData(for: workout, identifier: .heartRate) { samples, error in
				guard error == nil else {
					// Handle any errors
					return
				}
				workoutManager.generateWorkoutData(for: workout, of: .heartrate, with: samples ?? [])
				
			}
			workoutManager.getWorkoutData(for: workout, identifier: .stepCount) { samples, error in
				guard error == nil else {
					// Handle any errors
					return
				}
				
				workoutManager.generateWorkoutData(for: workout, of: .cadence, with: samples ?? [])
				
				workoutManager.generateWorkoutData(for: workout, of: .steps, with: samples ?? [])
			}
		})
	}
}

struct SingleWorkoutView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			SingleWorkoutView(workout: WorkoutManager.testWorkouts[0])
			SingleWorkoutView(workout: WorkoutManager.testWorkouts[1])
			
			Group {
				SingleWorkoutView(workout: WorkoutManager.testWorkouts[0])
				SingleWorkoutView(workout: WorkoutManager.testWorkouts[1])
			}
			.background(Color(.systemBackground))
			.environment(\.colorScheme, .dark)
		}
		.environmentObject(UserData())
		.environmentObject(WorkoutManager())
	}
}
