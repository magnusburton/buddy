//
//  ErrorHandling.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-10-25.
//

import Foundation

enum HealthKitError: Error {
	case noData
	case noAge
	case noGender
	case noPermission
	case invalidDate
	
	case unknown
}
