//
//  DateComponentsAge.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-16.
//

import Foundation

extension DateComponents {
	var age: Int? {
		return Calendar.current.dateComponents([.year], from: self.date ?? Date(), to: Date()).year
	}
}
