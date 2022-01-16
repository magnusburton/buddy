//
//  HeartRateZone+CoreDataClass.swift
//  Buddy
//
//  Created by Magnus Burton on 2022-01-05.
//
//

import Foundation
import CoreData

// MARK: - Core Data

public class HeartRateZone: NSManagedObject {
	@NSManaged public var id: UUID
	@NSManaged public var sampleCount: Int16
	@NSManaged fileprivate var heartZone: Int16
	@NSManaged public var version: Int16
	@NSManaged fileprivate var algorithmValue: Int16
	@NSManaged public var workout: Workout
	
	var zone: HealthTools.HeartRateZones {
		get {
			return HealthTools.HeartRateZones(rawValue: Int(self.heartZone)) ?? .undetermined
		}
		set {
			self.heartZone = Int16(newValue.rawValue)
		}
	}
	
	var algorithm: HealthTools.MaxHRAlgorithm {
		get {
			return HealthTools.MaxHRAlgorithm(rawValue: Int(self.algorithmValue)) ?? .haskell
		}
		set {
			self.algorithmValue = Int16(newValue.rawValue)
		}
	}
}

extension HeartRateZone: Identifiable {}

// MARK: - Fetch requests

extension HeartRateZone {
	@nonobjc public class func createFetchRequest() -> NSFetchRequest<HeartRateZone> {
		return NSFetchRequest<HeartRateZone>(entityName: "HeartRateZone")
	}
}
