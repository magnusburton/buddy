//
//  UserData.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import Foundation
import Combine
import HealthKit

public class UserData: ObservableObject {
	@Published var firstName: String? {
		didSet {
			UserDefaults.standard.set(firstName, forKey: "firstName")
		}
	}
	
	@Published var firstLaunch: Bool {
		didSet {
			UserDefaults.standard.set(firstLaunch, forKey: "firstLaunch")
		}
	}
	
	// Card views
	@Published var showFirstNameCard: Bool {
		didSet {
			UserDefaults.standard.set(showFirstNameCard, forKey: "showFirstNameCard")
		}
	}
	// User settings
	@Published var showHRZoneDetails: Bool {
		didSet {
			UserDefaults.standard.set(showHRZoneDetails, forKey: "showHRZoneDetails")
		}
	}
	@Published var includeWalks: Bool {
		didSet {
			UserDefaults.standard.set(includeWalks, forKey: "includeWalks")
		}
	}
	@Published var maxHR: Int? {
		didSet {
			UserDefaults.standard.set(maxHR, forKey: "maxHR")
		}
	}
	
	
	// User units
	@Published var unitDistance: HKUnit {
		didSet {
			UserDefaults.standard.set(unitDistance.unitString, forKey: "unitDistance")
		}
	}
	@Published var unitWeight: HKUnit {
		didSet {
			UserDefaults.standard.set(unitWeight.unitString, forKey: "unitWeight")
		}
	}
	@Published var unitEnergy: HKUnit {
		didSet {
			UserDefaults.standard.set(unitEnergy.unitString, forKey: "unitEnergy")
		}
	}
	
	init() {
		self.firstName = UserDefaults.standard.object(forKey: "firstName") as? String
		
		self.showFirstNameCard = UserDefaults.standard.object(forKey: "showFirstNameCard") as? Bool ?? true
		
		self.showHRZoneDetails = UserDefaults.standard.object(forKey: "showHRZoneDetails") as? Bool ?? false
		self.includeWalks = UserDefaults.standard.object(forKey: "includeWalks") as? Bool ?? true
		self.maxHR = UserDefaults.standard.object(forKey: "maxHR") as? Int
		self.firstLaunch = UserDefaults.standard.object(forKey: "firstLaunch") as? Bool ?? true
		
		self.unitDistance = HKUnit(from: UserDefaults.standard.object(forKey: "unitDistance") as? String ?? "km")
		self.unitWeight = HKUnit(from: UserDefaults.standard.object(forKey: "unitWeight") as? String ?? "kg")
		self.unitEnergy = HKUnit(from: UserDefaults.standard.object(forKey: "unitEnergy") as? String ?? "kcal")
	}
}
