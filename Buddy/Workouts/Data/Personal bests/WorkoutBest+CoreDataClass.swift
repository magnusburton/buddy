//
//  WorkoutBest+CoreDataClass.swift
//  Buddy
//
//  Created by Magnus Burton on 2022-01-06.
//
//

import Foundation
import CoreData

// MARK: - Core Data

public class WorkoutBest: NSManagedObject {
	@NSManaged public var id: UUID
	@NSManaged fileprivate var distanceId: Int16
	@NSManaged fileprivate var duration: Double
	@NSManaged fileprivate var startDate: Date
	@NSManaged public var version: Int16
	@NSManaged public var workout: Workout
	
	var best: PersonalBest {
		get {
			let distance = PersonalBestDistance(rawValue: Int(self.distanceId)) ?? .twoHundredMeters
			let interval = DateInterval(start: self.startDate, duration: self.duration)
			
			return PersonalBest(distance: distance, interval: interval)
		}
		set {
			if newValue.interval.duration < 0 {
				fatalError("Invalid duration!")
			}
			
			self.distanceId = Int16(newValue.distance.rawValue)
			self.duration = newValue.interval.duration
			self.startDate = newValue.interval.start
		}
	}
}

extension WorkoutBest: Identifiable {}

// MARK: - Fetch requests

extension WorkoutBest {
	@nonobjc public class func createFetchRequest() -> NSFetchRequest<WorkoutBest> {
		return NSFetchRequest<WorkoutBest>(entityName: "WorkoutBest")
	}
}
