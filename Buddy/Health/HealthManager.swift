//
//  HealthManager.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-16.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
	let HKManager = HealthKitManager()
	
	/// The raw value may be shown to the user as the type's `label`.
	enum DataType: String, CaseIterable {
		case hrv = "Heart Rate Variability"
		case rhr = "Resting Heart Rate"
		case bodyFat = "Body fat"
		case distance = "Distance walking and running"
		case steps = "Steps"
		case stairs = "Floors"
	}
	
	struct HealthData {
		var items: [HKQuantitySample] = []
		var dataType: DataType
		/// Unit related to this data, may be set to the user's chosen unit type
		var unit: HKUnit
		/// Quantity type identifier for queries from HealthKit
		var identifier: HKQuantityTypeIdentifier
		/// The type of `HKSample` this data is
		var type: HKSampleType
		/// Multiplier when showing data to the user
		var multiplier: Double = 1
		/// The direction the trend should slope for an increase in health
		var desiredSlope: InsightResult.ResultsKind
		////// What's considered "significant change" when comparing data for insights
		var threshold: Double = 0.5
		
		var label: String {
			self.dataType.rawValue
		}
	}
	
	@Published var hrv: [HKQuantitySample] = []
	@Published var data: [DataType: HealthData] = [:]
	@Published var insights: [Insight] = []
	
	/// The interval in months to fetch data
	private let dataInterval: Int = 2
	
	init() {
		data[.hrv] = .init(dataType: .hrv, unit: HKUnit.secondUnit(with: .milli), identifier: .heartRateVariabilitySDNN, type: HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!, desiredSlope: .up, threshold: 0.1)
		
		data[.rhr] = .init(dataType: .rhr, unit: HKUnit.count().unitDivided(by: .minute()), identifier: .restingHeartRate, type: HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!, desiredSlope: .down, threshold: 0.1)
		
		data[.bodyFat] = .init(dataType: .bodyFat, unit: HKUnit.percent(), identifier: .bodyFatPercentage, type: HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!, multiplier: 100, desiredSlope: .down, threshold: 0.01)
		
		data[.distance] = .init(dataType: .distance, unit: HKUnit.meter(), identifier: .distanceWalkingRunning, type: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!, multiplier: 1, desiredSlope: .up, threshold: 0.1)
		
		data[.steps] = .init(dataType: .steps, unit: HKUnit.count(), identifier: .stepCount, type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, multiplier: 1, desiredSlope: .up, threshold: 0.1)
		
		data[.stairs] = .init(dataType: .stairs, unit: HKUnit.count(), identifier: .flightsClimbed, type: HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!, multiplier: 1, desiredSlope: .up, threshold: 0.1)
	}
	
	func fetchBaseline(for identifier: HKQuantityTypeIdentifier, completion: @escaping (Bool?, Error?) -> Void) {
		HKManager.getHealthData(for: identifier) { results, error in
			if let error = error {
				print("Error fetching workouts: \(error)")
				completion(false, error)
			} else {
				self.hrv = results ?? []
				//self.data[.hrv]?.items = results ?? []
				completion(true, nil)
			}
		}
	}
}

extension HealthManager {
	/// Initiates an `HKAnchoredObjectQuery` for each type of data that the app reads and stores
	/// the result as well as the new anchor.
	///
	/// - parameter for: `HKObjectType` to fetch data for. Omitting this parameter will result in all authorized types being read.
	func readHealthKitData(for objType: HKObjectType? = nil) {
		var types: Set<HKObjectType> = HKManager.infoToRead
		
		if objType != nil {
			types = [objType!]
		}
		
		for type in types {
			var enumType: DataType?
			
			for healthType in DataType.allCases {
				if type == data[healthType]?.type {
					enumType = healthType
				}
			}
			
			if enumType == nil {
				debugPrint("*** Health type ", type, " not assigned a data store in HealthManager yet. ***")
				break;
			}
			
			guard let startDate = Calendar.current.date(byAdding: .month, value: -dataInterval, to: Date()) else {
				fatalError("*** Unable to create the start date ***")
			}
			let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictEndDate)
			
			let query = HKAnchoredObjectQuery(type: type as! HKSampleType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
				
				guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
					// Properly handle the error.
					return
				}
				
				//				myAnchor = newAnchor
				
				if self.data[enumType!]?.type.isKind(of: HKQuantityType.self) == true {
					guard let quantitySamples = samples as? [HKQuantitySample] else { return }
					
					DispatchQueue.main.async {
						self.data[enumType!]?.items = quantitySamples
					}
				}
				
				for sample in deletedObjects {
					print(sample)
					// Process the deleted step count samples.
				}
				
				// The results come back on an anonymous background queue.
				// Dispatch to the main queue before modifying the UI.
				
				DispatchQueue.main.async {
					// Update the UI here.
				}
			}
			HKManager.healthStore.execute(query)
		}
	}
	
	func initStore() {
		readHealthKitData()
		setUpBackgroundDeliveryForDataTypes(types: HKManager.infoToRead)
	}
	
	/// Sets up the observer queries for background health data delivery.
	///
	/// - parameter types: Set of `HKObjectType` to observe changes to.
	private func setUpBackgroundDeliveryForDataTypes(types: Set<HKObjectType>) {
		for type in types {
			guard let sampleType = type as? HKSampleType else { print("ERROR: \(type) is not an HKSampleType"); continue }
			
			guard let startDate = Calendar.current.date(byAdding: .month, value: -dataInterval, to: Date()) else {
				fatalError("*** Unable to create the start date ***")
			}
			let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictEndDate)
			
			let query = HKObserverQuery(sampleType: sampleType, predicate: predicate) { [weak self] (query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: Error?) in
				
				debugPrint("*** observer query update handler called for type \(type), error: \(String(describing: error)) ***")
				guard let strongSelf = self else { return }
				
				strongSelf.queryForUpdates(type: type)
				completionHandler()
			}
			
			HKManager.healthStore.execute(query)
			HKManager.healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { (success: Bool, error: Error?) in
				debugPrint("*** enableBackgroundDeliveryForType handler called for \(type) - success: \(success), error: \(String(describing: error)) ***")
			}
		}
	}
	
	/// Initiates HK queries for new data based on the given type
	///
	/// - parameter type: `HKObjectType` which has new data avilable.
	private func queryForUpdates(type: HKObjectType) {
		switch type {
			case HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!:
				debugPrint("heartRateVariabilitySDNN")
				readHealthKitData(for: type)
			case HKSampleType.quantityType(forIdentifier: .restingHeartRate)!:
				debugPrint("restingHeartRate")
				readHealthKitData(for: type)
			case HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!:
				debugPrint("bodyFatPercentage")
				readHealthKitData(for: type)
			case HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!:
				debugPrint("distanceWalkingRunning")
				readHealthKitData(for: type)
			case HKSampleType.quantityType(forIdentifier: .stepCount)!:
				debugPrint("stepCount")
				readHealthKitData(for: type)
			case HKSampleType.quantityType(forIdentifier: .flightsClimbed)!:
				debugPrint("flightsClimbed")
				readHealthKitData(for: type)
			default: debugPrint("Unhandled HKObjectType: \(type)")
		}
	}
}
