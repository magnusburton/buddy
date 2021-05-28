//
//  Workouts.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-14.
//

import Foundation
import HealthKit

extension WorkoutManager {
	static let testWorkouts: [WorkoutManager.Workout] = [
		.init(workout: HKWorkout(
			activityType: .running,
			start: Calendar.current.date(byAdding: .minute, value: -63, to: Date())!,
			end: Date(),
			workoutEvents: [],
			totalEnergyBurned:
				HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 400.0),
			totalDistance:
				HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 5.02),
			metadata: [:]
		)),
		.init(workout: HKWorkout(
			activityType: .walking,
			start: Calendar.current.date(byAdding: .minute, value: -21, to: Date())!,
			end: Date(),
			workoutEvents: [],
			totalEnergyBurned:
				HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 120),
			totalDistance:
				HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 2.42),
			metadata: [:]
		)),
		.init(workout: HKWorkout(
			activityType: .running,
			start: Calendar.current.date(byAdding: .minute, value: -87, to: Date())!,
			end: Date(),
			workoutEvents: [],
			totalEnergyBurned:
				HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 546.0),
			totalDistance:
				HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 7.02),
			metadata: [:]
		)),
		.init(workout: HKWorkout(
			activityType: .running,
			start: Calendar.current.date(byAdding: .minute, value: -23, to: Date())!,
			end: Date(),
			workoutEvents: [],
			totalEnergyBurned:
				HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 194),
			totalDistance:
				HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 2.0),
			metadata: [:]
		)),
		.init(workout: HKWorkout(
			activityType: .walking,
			start: Calendar.current.date(byAdding: .minute, value: -45, to: Date())!,
			end: Date(),
			workoutEvents: [],
			totalEnergyBurned:
				HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 206.0),
			totalDistance:
				HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 5.02),
			metadata: [:]
		)),
		.init(workout: HKWorkout(
			activityType: .running,
			start: Calendar.current.date(byAdding: .minute, value: -89, to: Date())!,
			end: Date(),
			workoutEvents: [],
			totalEnergyBurned:
				HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 700.0),
			totalDistance:
				HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 15.02),
			metadata: [:]
		))
	]
	
	static let heartRateIdentifier = HKSampleType.quantityType(forIdentifier: .heartRate)
	static let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
	
	static let testHeartRate: [HKQuantitySample] = [
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 50.0), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 22), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 65), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 98), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 187), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 192), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 137), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 84), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 128), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 178), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 170), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 143), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 135), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 99), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 147), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 110), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 140), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 160), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 132), start: Date(), end: Date().addingTimeInterval(3)),
		.init(type: heartRateIdentifier!, quantity: .init(unit: heartRateUnit, doubleValue: 99), start: Date(), end: Date().addingTimeInterval(3)),
	]
}
