//
//  WorkoutExertion+CoreDataClass.swift
//  Buddy
//
//  Created by Magnus Burton on 2022-01-05.
//
//

import Foundation
import CoreData

// MARK: - Core Data

public class WorkoutExertion: NSManagedObject {
	@NSManaged public var id: UUID
	@NSManaged public var exertion: Double
	@NSManaged public var version: Int16
	@NSManaged fileprivate var algorithmValue: Int16
	@NSManaged public var workout: Workout
	
	var algorithm: HealthTools.MaxHRAlgorithm {
		get {
			return HealthTools.MaxHRAlgorithm(rawValue: Int(self.algorithmValue)) ?? .haskell
		}
		set {
			self.algorithmValue = Int16(newValue.rawValue)
		}
	}
}

extension WorkoutExertion: Identifiable {}

// MARK: - Fetch requests

extension WorkoutExertion {
	@nonobjc public class func createFetchRequest() -> NSFetchRequest<WorkoutExertion> {
		return NSFetchRequest<WorkoutExertion>(entityName: "WorkoutExertion")
	}
}
