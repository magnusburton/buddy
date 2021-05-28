//
//  WorkoutManager.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-06.
//

import Foundation
import HealthKit

class WorkoutManager: ObservableObject {
	let HKManager = HealthKitManager()
	
	@Published var data: [Workout] = []
	@Published var personalBests: [PersonalBest] = []//loadPersonalBests()
	
	enum DataType: CaseIterable {
		case cadence
		case pace
		case heartrate
		case split
		case steps
		case distance
	}
	
	struct WorkoutData {
		var items: [WorkoutDataSample] = []
		/// String indicating what type of data this relates to, may be shown to the user
		var label: String
		/// Unit related to this data, may be set to the user's chosen unit type
		var unit: HKUnit
		
		/// Represents the `WorkoutData` as a line chart `Line`
		var line: Line {
			let points: [Point] = self.items.map {
				if let sample = $0.quantitySample {
					return Point(sample: sample, unit: self.unit)
				} else {
					return Point(quantity: $0.quantity, date: $0.endDate, unit: self.unit)
				}
			}
			return Line(points: points, label: self.label)
		}
	}
	
	struct Workout: Identifiable {
		var id: UUID
		var workout: HKWorkout
		var type: HKWorkoutActivityType
		var processed = false
		
		var data: [DataType: WorkoutManager.WorkoutData] = [:]
		
		init(workout: HKWorkout) {
			self.id = workout.uuid
			self.workout = workout
			self.type = workout.workoutActivityType
			
			data[.cadence] = .init(label: "Cadence", unit: HKUnit.count().unitDivided(by: .minute()))
			data[.pace] = .init(label: "Pace", unit: HKUnit.second().unitDivided(by: .meterUnit(with: .kilo))) /// Todo: Fix this with user unit
			data[.heartrate] = .init(label: "Heart Rate", unit: HKUnit.count().unitDivided(by: .minute()))
			data[.split] = .init(label: "Splits", unit: HKUnit.count().unitDivided(by: .minute()))
			data[.steps] = .init(label: "Steps", unit: HKUnit.count())
			data[.distance] = .init(label: "Distance", unit: HKUnit.meterUnit(with: .kilo)) /// Todo: Fix this with user unit
		}
	}
	
	/// The interval in months to fetch data
	private let dataInterval: Int? = nil
	
	func getWorkoutData(for workout: Workout, identifier: HKQuantityTypeIdentifier, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
		guard let sampleType = HKSampleType.quantityType(forIdentifier: identifier) else {
			fatalError("*** This method should never fail ***")
		}
		
		HKManager.getWorkoutData(for: workout.workout, sampleType: sampleType) { samples, error in
			completion(samples, error)
			
			//let pbs = self.findPersonalBest(for: workout.workout, with: samples ?? [])
			//print(pbs)
		}
	}
}

extension WorkoutManager {
	/// Initiates an `HKAnchoredObjectQuery` for each type of data that the app reads and stores
	/// the result as well as the new anchor.
	func readData() {
		let compound = NSCompoundPredicate(orPredicateWithSubpredicates:
											[HKQuery.predicateForWorkouts(with: .walking),
											 HKQuery.predicateForWorkouts(with: .running)
											 /*HKQuery.predicateForWorkouts(with: .hiking)*/])
		var predicateArray: [NSPredicate] = [compound]
		
		if let monthPeriod = dataInterval {
			guard let startDate = Calendar.current.date(byAdding: .month, value: -monthPeriod, to: Date()) else {
				fatalError("*** Unable to create the start date ***")
			}
			let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictEndDate)
			predicateArray.append(contentsOf: [datePredicate])
		}
		
		let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
		
		let query = HKAnchoredObjectQuery(type: HKWorkoutType.workoutType(), predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
			
			guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
				// Properly handle the error.
				return
			}
			
			guard let workouts = samples as? [HKWorkout] else { return }
			
			DispatchQueue.main.async {
				self.data = workouts.sorted { $0.startDate > $1.startDate }.map { Workout(workout: $0) }
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
	
	func initStore() {
		readData()
		setUpBackgroundDeliveryForDataTypes(types: HKManager.infoToRead)
	}
	
	/// Sets up the observer queries for background health data delivery.
	///
	/// - parameter types: Set of `HKObjectType` to observe changes to.
	private func setUpBackgroundDeliveryForDataTypes(types: Set<HKObjectType>) {
		for type in types {
			guard let sampleType = type as? HKSampleType else { print("ERROR: \(type) is not an HKSampleType"); continue }
			
			var predicate: NSPredicate?
			if let monthPeriod = dataInterval {
				guard let startDate = Calendar.current.date(byAdding: .month, value: -monthPeriod, to: Date()) else {
					fatalError("*** Unable to create the start date ***")
				}
				predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictEndDate)
			}
			
			let query = HKObserverQuery(sampleType: sampleType, predicate: predicate) { [weak self] (query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: Error?) in
				
				debugPrint("*** observer query update handler called for type \(type), error: \(String(describing: error))")
				guard let strongSelf = self else { return }
				
				strongSelf.queryForUpdates(type: type)
				completionHandler()
			}
			
			HKManager.healthStore.execute(query)
			HKManager.healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { (success: Bool, error: Error?) in
				debugPrint("*** enableBackgroundDeliveryForType handler called for \(type) - success: \(success), error: \(String(describing: error))")
			}
		}
	}
	
	/// Initiates HK queries for new data based on the given type
	///
	/// - parameter type: `HKObjectType` which has new data avilable.
	private func queryForUpdates(type: HKObjectType) {
		switch type {
			case is HKWorkoutType:
				debugPrint("HKWorkoutType")
				readData()
			default: debugPrint("Unhandled HKObjectType: \(type)")
		}
	}
	
	func generateWorkoutData(for workout: Workout, of type: DataType, with samples: [HKQuantitySample]) {
		var array: [WorkoutDataSample] = []
		
		if type == .cadence {
			array = samples.map {
				let sample = $0
				let sampleValue: Double = sample.quantity.doubleValue(for: HKUnit.count())
				
				let duration: TimeInterval = DateInterval(start: sample.startDate, end: sample.endDate).duration
				let cadence: Double = sampleValue / (duration / 60)
				
				let unit = workout.data[type]!.unit
				let quantity = HKQuantity(unit: unit, doubleValue: cadence)
				
				let interval = DateInterval(start: sample.startDate, end: sample.endDate)
				
				/// This causes a crash if the unit of the quantity doesn't match the sample type
				return WorkoutDataSample(quantity: quantity, interval: interval)
			}
		} else if type == .pace {
			array = samples.map {
				let sample = $0
				let sampleValue: Double = sample.quantity.doubleValue(for: HKUnit.meter())
				
				let duration: TimeInterval = DateInterval(start: sample.startDate, end: sample.endDate).duration
				let pace: Double = sampleValue / (duration / 60)
				
				let unit = workout.data[type]!.unit
				let quantity = HKQuantity(unit: unit, doubleValue: pace)
				
				let interval = DateInterval(start: sample.startDate, end: sample.endDate)
				
				/// This causes a crash if the unit of the quantity doesn't match the sample type
				return WorkoutDataSample(quantity: quantity, interval: interval)
			}
		} else if type == .heartrate {
			array = samples.map {
				$0.workoutDataSample
			}
		} else if type == .steps {
			array = samples.map {
				$0.workoutDataSample
			}
		} else if type == .distance {
			array = samples.map {
				$0.workoutDataSample
			}
		} else {
			debugPrint("Invalid DataType: ", type)
			return
		}
		
		DispatchQueue.main.async {
			if let index = self.data.firstIndex(where: { workout == $0 }) {
				self.data[index].data[type]?.items = array
			}
		}
	}
}
