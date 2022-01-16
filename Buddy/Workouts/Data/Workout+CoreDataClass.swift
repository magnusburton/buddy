//
//  Workout+CoreDataClass.swift
//  Buddy
//
//  Created by Magnus Burton on 2022-01-09.
//
//

import Foundation
import CoreData
import HealthKit

// MARK: - Core Data

@objc(Workout)
public class Workout: NSManagedObject {
	@NSManaged public var id: UUID
	@NSManaged private var activityTypeValue: Int16
	@NSManaged public var endDate: Date
	@NSManaged public var processed: Bool
	@NSManaged public var startDate: Date
	@NSManaged private var totalDistance: Double
	@NSManaged private var totalEnergyBurned: Double
	@NSManaged public var insertedAt: Date
	@NSManaged public var bests: NSSet
	@NSManaged public var exertion: NSSet
	@NSManaged public var zones: NSSet
	
	var activityType: HKWorkoutActivityType {
		get {
			return HKWorkoutActivityType(rawValue: UInt(self.activityTypeValue)) ?? .running
		}
		set {
			self.activityTypeValue = Int16(newValue.rawValue)
		}
	}
	
	var distance: HKQuantity {
		get {
			return HKQuantity(unit: .meterUnit(with: .kilo), doubleValue: self.totalDistance)
		}
		set {
			self.totalDistance = newValue.doubleValue(for: .meterUnit(with: .kilo))
		}
	}
	
	var energyBurned: HKQuantity {
		get {
			return HKQuantity(unit: .kilocalorie(), doubleValue: self.totalEnergyBurned)
		}
		set {
			self.totalEnergyBurned = newValue.doubleValue(for: .kilocalorie())
		}
	}
	
	var interval: DateInterval {
		get {
			return DateInterval(start: self.startDate, end: self.endDate)
		}
		set {
			self.startDate = newValue.start
			self.endDate = newValue.end
		}
	}
}

extension Workout: Identifiable {}

// MARK: Generated accessors for bests
extension Workout {
	
	@objc(addBestsObject:)
	@NSManaged public func addToBests(_ value: WorkoutBest)
	
	@objc(removeBestsObject:)
	@NSManaged public func removeFromBests(_ value: WorkoutBest)
	
	@objc(addBests:)
	@NSManaged public func addToBests(_ values: NSSet)
	
	@objc(removeBests:)
	@NSManaged public func removeFromBests(_ values: NSSet)
	
}

// MARK: Generated accessors for exertion
extension Workout {
	
	@objc(addExertionObject:)
	@NSManaged public func addToExertion(_ value: WorkoutExertion)
	
	@objc(removeExertionObject:)
	@NSManaged public func removeFromExertion(_ value: WorkoutExertion)
	
	@objc(addExertion:)
	@NSManaged public func addToExertion(_ values: NSSet)
	
	@objc(removeExertion:)
	@NSManaged public func removeFromExertion(_ values: NSSet)
	
}

// MARK: Generated accessors for zones
extension Workout {
	
	@objc(addZonesObject:)
	@NSManaged public func addToZones(_ value: HeartRateZone)
	
	@objc(removeZonesObject:)
	@NSManaged public func removeFromZones(_ value: HeartRateZone)
	
	@objc(addZones:)
	@NSManaged public func addToZones(_ values: NSSet)
	
	@objc(removeZones:)
	@NSManaged public func removeFromZones(_ values: NSSet)
	
}

// MARK: - Fetch requests

extension Workout {
	@nonobjc public class func createFetchRequest() -> NSFetchRequest<Workout> {
		return NSFetchRequest<Workout>(entityName: "Workout")
	}
}
