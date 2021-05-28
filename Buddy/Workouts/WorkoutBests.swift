//
//  WorkoutBests.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-04-15.
//

import Foundation
import HealthKit

extension WorkoutManager {
	/// Allowed distances for personal best scores
	static let allowedDistances: [PersonalBestDistance] = [
		.init(id: "200m", distance: .init(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 0.2), label: "200m"),
		.init(id: "400m", distance: .init(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 0.4), label: "400m"),
		.init(id: "500m", distance: .init(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 0.5), label: "500m"),
		.init(id: "1k", distance: .init(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 1), label: "1K"),
		.init(id: "5k", distance: .init(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 5), label: "5K"),
		.init(id: "10k", distance: .init(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 10), label: "10K"),
		.init(id: "halfmara", distance: .init(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 21.0975), label: "Half Marathon"),
		.init(id: "mara", distance: .init(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 42.195), label: "Marathon"),
		
		.init(id: "halfmi", distance: .init(unit: HKUnit.mile(), doubleValue: 0.5), label: ".5mi"),
		.init(id: "1mi", distance: .init(unit: HKUnit.mile(), doubleValue: 1), label: "1mi"),
		.init(id: "5mi", distance: .init(unit: HKUnit.mile(), doubleValue: 5), label: "5mi"),
		.init(id: "10mi", distance: .init(unit: HKUnit.mile(), doubleValue: 10), label: "10mi")
	]
	
	/// Describes an available personal best distance
	struct PersonalBestDistance: Identifiable {
		var id: String
		var distance: HKQuantity
		var label: String
	}
	
	/// Contains the user's personal best and the corresponding workout for a given `PersonalBestDistance`
	struct PersonalBest {
		var distance: PersonalBestDistance
		var workout: UUID?
		var interval: DateInterval?
	}
	
	func loadPersonalBests() -> [PersonalBest] {
		let unit = HKUnit.meterUnit(with: .kilo)
		let sortedDistances = WorkoutManager.allowedDistances.sorted {
			$0.distance.doubleValue(for: unit) < $1.distance.doubleValue(for: unit)
		}
		return sortedDistances.map { .init(distance: $0) }
	}
	
	func findPersonalBest(for workout: HKWorkout, with givenDistances: [HKQuantitySample]) -> [PersonalBest] {
		guard let totalDistance = workout.totalDistance else {
			// Workout doesn't include distance
			return []
		}
		
		guard givenDistances.count > 0 else {
			// Workout doesn't include distance
			return []
		}
		
		let unit = HKUnit.meter()
		let _ = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
		let uuid = workout.uuid
		
		let distances = givenDistances.sorted { $0.startDate < $1.startDate }
		let _ = distances.map { $0.quantity.doubleValue(for: unit) }
		
		var pbs: [PersonalBest] = []
		
		for item in WorkoutManager.allowedDistances {
			if totalDistance.compare(item.distance) == .orderedAscending {
				// Workout is too short compared to current distance
				continue
			}
			
			let dstCheck = item.distance.doubleValue(for: unit)
			var fastestPaceInterval: DateInterval?
			var fastestPacePace: Double?
			
			var fragment: [HKQuantitySample] = []
			
			// Loop through workout distance items to find fastest interval
			for (_, dst) in distances.enumerated() {
				let sum = fragment.sum(unit: unit)
				if sum >= dstCheck {
					let firstItem = fragment.first!
					let lastItem = fragment.last!
					let lastQuantity = lastItem.quantity.doubleValue(for: unit)
					let lastDuration = lastItem.endDate.timeIntervalSince(lastItem.startDate)
					
					let diff = sum - dstCheck
					let percentage = diff / lastQuantity
					
					let interpolatedEndDate = lastItem.startDate.addingTimeInterval(lastDuration * percentage)

					// Check if fastest pace yet
					let duration = interpolatedEndDate.timeIntervalSince(firstItem.startDate)
					let pace = duration / dstCheck
					
					if pace < fastestPacePace ?? .infinity {
						fastestPacePace = pace
						fastestPaceInterval = DateInterval(start: firstItem.startDate, end: interpolatedEndDate)
					}
					
					// Remove first from workout fragment and start over
					fragment.removeFirst()
				}
				
				fragment.append(dst)
			}
			
			if fastestPacePace != nil && fastestPaceInterval != nil {
				let pb = PersonalBest(distance: item, workout: uuid, interval: fastestPaceInterval)
				pbs.append(pb)
			}
		}
		return pbs
	}
}
