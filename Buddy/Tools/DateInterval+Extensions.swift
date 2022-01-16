//
//  DateInterval+Extensions.swift
//  Buddy
//
//  Created by Magnus Burton on 2022-01-12.
//

import Foundation

extension DateInterval {
	var range: Range<Date> {
		start..<end
	}
}
