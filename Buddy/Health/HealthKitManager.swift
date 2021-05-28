//
//  HealthKitManager.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
	public let healthStore = HKHealthStore()
	
	public let infoToRead: Set<HKObjectType> = [
		HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
		HKSampleType.quantityType(forIdentifier: .restingHeartRate)!,
		
		HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!,
		
		HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
		HKSampleType.quantityType(forIdentifier: .stepCount)!,
		
		HKCharacteristicType.characteristicType(forIdentifier: .biologicalSex)!,
		HKCharacteristicType.characteristicType(forIdentifier: .dateOfBirth)!,
		
		HKWorkoutType.workoutType()
	]
	
	func authorizeHealthKit(completion: @escaping (Bool?, Error?) -> Void) {
		if HKHealthStore.isHealthDataAvailable() {
			healthStore.requestAuthorization(toShare: nil, read: infoToRead) { (success, error) in
				if let error = error {
					print("Error requesting HealthKit authorization: \(error)")
					completion(nil, error)
				} else {
					completion(success, nil)
				}
			}
		} else {
			print("HealthKit not available")
			completion(nil, nil)
		}
	}
}

extension HealthKitManager {
	func getHealthData(for identifier: HKQuantityTypeIdentifier, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
		let calendar = Calendar.current
		let now = Date()
		let components = calendar.dateComponents([.year, .month, .day], from: now)
		
		guard let endDate = calendar.date(from: components) else {
			fatalError("*** Unable to create the end date ***")
		}
		
		guard let startDate = calendar.date(byAdding: .month, value: -2, to: endDate) else {
			fatalError("*** Unable to create the start date ***")
		}
		
		let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
		
		guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
			completion(nil, nil)
			fatalError("*** Unable to create quantity type ***")
		}
		
		let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
		
		// Create the query
		let query = HKSampleQuery(sampleType: quantityType, predicate: datePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortByDate]) { query, samples, error in
			
			guard let samples = samples as? [HKQuantitySample], error == nil else {
				completion(nil, error)
				return
			}
			
			// The results come back on an anonymous background queue.
			// Dispatch to the main queue before modifying the UI.
			
			DispatchQueue.main.async {
				completion(samples, nil)
			}
		}
		
		healthStore.execute(query)
	}
}

extension HealthKitManager {
	func getWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
		let compound = NSCompoundPredicate(orPredicateWithSubpredicates:
											[HKQuery.predicateForWorkouts(with: .walking),
											 HKQuery.predicateForWorkouts(with: .running)
											 /*HKQuery.predicateForWorkouts(with: .hiking)*/])
		
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
											  ascending: false)
		
		let query = HKSampleQuery(
			sampleType: .workoutType(),
			predicate: compound,
			limit: HKObjectQueryNoLimit,
			sortDescriptors: [sortDescriptor]) { (query, samples, error) in
			DispatchQueue.main.async {
				guard let samples = samples as? [HKWorkout], error == nil else {
					completion(nil, error)
					return
				}
				
				completion(samples, nil)
			}
		}
		
		healthStore.execute(query)
	}
	
	func getWorkoutData(for workout: HKWorkout, sampleType: HKSampleType, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
		let predicate = HKQuery.predicateForObjects(from: workout)
		
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
											  ascending: true)
		
		let query = HKSampleQuery(
			sampleType: sampleType,
			predicate: predicate,
			limit: HKObjectQueryNoLimit,
			sortDescriptors: [sortDescriptor]) { (query, samples, error) in
			DispatchQueue.main.async {
				guard let samples = samples as? [HKQuantitySample], error == nil else {
					completion(nil, error)
					return
				}
				
				completion(samples, nil)
			}
		}
		
		healthStore.execute(query)
	}
}
