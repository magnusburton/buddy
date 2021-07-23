//
//  ChartPointView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-05.
//

import Foundation
import SwiftUI
import HealthKit

/// Single point to be represented in the line
public struct Point {
	@Environment(\.chartStyle) var chartStyle
	
	/// Any floating point number on the horizontal axis
	public let x: Double
	/// Any floating point number on the vertical axis
	public let y: Double
	/// Date representing the point
	public var date: Date?
	/// Sample representing the point
	public var sample: HKQuantitySample?
	/// Default color for the point in not selected state
	public var color: Color = .accentColor
	/// Optional label for horizontal axis
	public var label: String?
	/// Convert to `CGPoint`
	public var asCGPoint: CGPoint {
		return CGPoint(x: self.x, y: self.y)
	}
	
	/// Init point with a simple x,y pair
	init(x: Double, y: Double) {
		self.x = x
		self.y = y
	}
	
	/// Init point with a simple x,y pair with a CGFloat
	init(x: Double, asCGFloat y: CGFloat) {
		self.x = x
		self.y = Double(y)
	}
	
	/// Init point with a date and a value
	init(date: Date, y: Double) {
		self.x = date.timeIntervalSince1970
		self.date = date
		
		self.y = y
	}
	
	/// Init point with a HealthKit quantity sample
	init(sample: HKQuantitySample, unit: HKUnit) {
		self.x = sample.endDate.timeIntervalSince1970
		self.date = sample.endDate
		
		self.y = sample.quantity.doubleValue(for: unit)
		self.sample = sample
	}
	
	/// Init point with a HealthKit quantity and date
	init(quantity: HKQuantity, date: Date, unit: HKUnit) {
		self.x = date.timeIntervalSince1970
		self.date = date
		
		self.y = quantity.doubleValue(for: unit)
	}
	
	private var style: LineChartStyle {
		(chartStyle as? LineChartStyle) ?? .init()
	}
}

extension Point: Identifiable {
	public var id: String {
		UUID().uuidString
	}
}

extension Point: Equatable {
	public static func == (lhs: Point, rhs: Point) -> Bool {
		lhs.id == rhs.id
	}
	
	public static func < (lhs: Point, rhs: Point) -> Bool {
		lhs.y < rhs.y
	}
}
