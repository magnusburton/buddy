//
//  HealthKitCharacteristics.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-16.
//

import HealthKit

extension HealthKitManager {
	var dateOfBirth: DateComponents? {
		do {
			let components = try healthStore.dateOfBirthComponents()
			return components
		} catch let error {
			print("Reading characteristic DOB data: \(error)")
		}
		return nil
	}
	
	var biologicalSex: HKBiologicalSex? {
		do {
			let data = try healthStore.biologicalSex().biologicalSex
			return data
		} catch let error {
			print("Reading characteristic biological sex data: \(error)")
		}
		return nil
	}
}
