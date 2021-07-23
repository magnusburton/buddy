//
//  ChartLineView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-05.
//

import Foundation
import SwiftUI

/// Single line to be displayed in a line chart
/// Todo: Fix big datasets
public struct Line: View {
	@Environment(\.chartStyle) var chartStyle
	
	public let points: [Point]
	public let label: String
	public var color: Color = .accentColor
	public var curvedLine: Bool = false
	public var multiplier: Double = 1
	public var showPoints: Bool = false
	public var pointsOnly: Bool = false
	
	public var isTimeline: Bool = false
	
	static var dotDimension: CGFloat = 3.0
	static var dotCornerSize: CGSize {
		CGSize(width: Line.dotDimension, height: dotDimension)
	}
	public var pathStyle: StrokeStyle = StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round)
	public let path: Path
	
	private var style: LineChartStyle {
		(chartStyle as? LineChartStyle) ?? .init()
	}
	
	init(points: [Point], label: String, color: Color = .accentColor, curvedLine: Bool = false, multiplier: Double = 1, showPoints: Bool = false, pointsOnly: Bool = false) {
		self.points = points
		self.label = label
		self.color = color
		self.curvedLine = curvedLine
		self.multiplier = multiplier
		self.showPoints = showPoints
		self.pointsOnly = pointsOnly
		
		if let first = points.first, first.date != nil {
			self.isTimeline = true
		}
		
		self.path = Line.makePath(points: points, curvedLine: curvedLine, pointsOnly: pointsOnly)
	}
	
	private var minYValue: CGFloat {
		let min = points.min { a, b in a.y < b.y }?.y
		return CGFloat(min ?? Double.leastNonzeroMagnitude)
	}
	
	private var minXValue: CGFloat {
		let min = points.min { a, b in a.x < b.x }?.x
		return CGFloat(min ?? Double.leastNonzeroMagnitude)
	}
	
	private var maxYValue: CGFloat {
		let max = points.max { a, b in a.y < b.y }?.y
		return CGFloat(max ?? Double.leastNonzeroMagnitude)
	}
	
	private var maxXValue: CGFloat {
		let max = points.max { a, b in a.x < b.x }?.x
		return CGFloat(max ?? Double.leastNonzeroMagnitude)
	}
	
	private var diffYValue: CGFloat {
		let diff = maxYValue - minYValue
		if diff > 0 {
			return diff
		}
		return .leastNonzeroMagnitude
	}
	
	private var diffXValue: CGFloat {
		let diff = maxXValue - minXValue
		if diff > 0 {
			return diff
		}
		return .leastNonzeroMagnitude
	}
	
	public var min: Point {
		return points.min { a, b in a.y < b.y } ?? Point(x: 0, y: 0)
	}
	
	public var max: Point {
		return points.max { a, b in a.y < b.y } ?? Point(x: 0, y: 0)
	}
	
	public var first: Point {
		return points.min { a, b in a.x < b.x } ?? Point(x: 0, y: 0)
	}
	
	public var last: Point {
		return points.max { a, b in a.x < b.x } ?? Point(x: 0, y: 0)
	}
	
	public var sum: Double {
		let allValues = points.map { $0.y }
		return allValues.reduce(0, +)
	}
	
	public var average: Double {
		let sum = self.sum
		return sum / Double(points.count)
	}
	
	public var count: Int {
		return self.points.count
	}
	
	public var allYValues: [Double] {
		return points.map { $0.y }
	}
	
	public var allXValues: [Double] {
		return points.map { $0.x }
	}
	
	static func makePath(points: [Point], curvedLine: Bool, pointsOnly: Bool) -> Path {
		var path = Path()
		if (points.count < 2){
			return path
		}
		
		var minYValue: CGFloat {
			let min = points.min { a, b in a.y < b.y }?.y
			return CGFloat(min ?? Double.leastNonzeroMagnitude)
		}
		
		var minXValue: CGFloat {
			let min = points.min { a, b in a.x < b.x }?.x
			return CGFloat(min ?? Double.leastNonzeroMagnitude)
		}
		
		var maxYValue: CGFloat {
			let max = points.max { a, b in a.y < b.y }?.y
			return CGFloat(max ?? Double.leastNonzeroMagnitude)
		}
		
		var maxXValue: CGFloat {
			let max = points.max { a, b in a.x < b.x }?.x
			return CGFloat(max ?? Double.leastNonzeroMagnitude)
		}
		
		var diffYValue: CGFloat {
			let diff = maxYValue - minYValue
			if diff > 0 {
				return diff
			}
			return .leastNonzeroMagnitude
		}
		
		var diffXValue: CGFloat {
			let diff = maxXValue - minXValue
			if diff > 0 {
				return diff
			}
			return .leastNonzeroMagnitude
		}
		
		let height: CGFloat = 1
		let width: CGFloat = 1
		
//		let stepX = points.min { a, b in a.x < b.x }?.x ?? 0
//		let stepY = points.min { a, b in a.y < b.y }?.y ?? 0
		let step = Point(x: Double(width) / Double(diffXValue), y: Double(height) / Double(diffYValue))
		
		let initialPoint: Point = points.first!
		
		let initialX: Double = initialPoint.x * step.x - Double(width * minXValue / diffXValue)
		let initialY: Double = initialPoint.y * step.y - Double(height * minYValue / diffYValue)
		
		if pointsOnly {
			let rect = CGRect(x: CGFloat(initialX), y: CGFloat(initialY), width: Line.dotDimension, height: Line.dotDimension)
			path.addRoundedRect(in: rect, cornerSize: Line.dotCornerSize)
		} else {
			path.move(to: Point(x: initialX, y: initialY).asCGPoint)
		}
		
		for pointIndex in 1..<points.count {
			let point = points[pointIndex]
			
			let x: Double = point.x * step.x - Double(width * minXValue / diffXValue)
			let y: Double = point.y * step.y - Double(height * minYValue / diffYValue)
			
			if pointsOnly {
				let rect = CGRect(x: CGFloat(x), y: CGFloat(y), width: dotDimension, height: dotDimension)
				dump(rect)
				path.addRoundedRect(in: rect, cornerSize: dotCornerSize)
			} else {
				path.addLine(to: Point(x: x, y: y).asCGPoint)
			}
		}
		return path
	}
	
	private let lineRadius = 0.5
	
	public var body: some View {
		GeometryReader { geometry in
			Path { path in
				if self.points.count < 2 {
					return
				}
				let height = geometry.size.height
				let width = geometry.size.width

//				let stepX = points.min { a, b in a.x < b.x }?.x ?? 0
//				let stepY = points.min { a, b in a.y < b.y }?.y ?? 0
				let step = Point(x: Double(width) / Double(self.diffXValue), y: Double(height) / Double(self.diffYValue))

				let initialPoint: Point = self.points.first!

				let initialX: Double = initialPoint.x * step.x - Double(width * self.minXValue / self.diffXValue)
				let initialY: Double = Double(height) - (initialPoint.y * step.y - Double(height * self.minYValue / self.diffYValue))
				
				if pointsOnly {
					let rect = CGRect(x: CGFloat(initialX), y: CGFloat(initialX), width: Line.dotDimension, height: Line.dotDimension)
					path.addRoundedRect(in: rect, cornerSize: Line.dotCornerSize)
				} else {
					path.move(to: Point(x: initialX, y: initialY).asCGPoint)
				}

				for pointIndex in 1..<points.count {
					let point = self.points[pointIndex]

					let x: Double = point.x * step.x - Double(width * self.minXValue / self.diffXValue)
					let y: Double = Double(height) - (point.y * step.y - Double(height * self.minYValue / self.diffYValue))

					if pointsOnly {
						let rect = CGRect(x: CGFloat(x), y: CGFloat(y), width: Line.dotDimension, height: Line.dotDimension)
						path.addRoundedRect(in: rect, cornerSize: Line.dotCornerSize)
					} else {
						path.addLine(to: Point(x: x, y: y).asCGPoint)
					}
				}
			}
//			self.path
//				.scale(x: geometry.size.width, y: geometry.size.height, anchor: .topLeading)
				.stroke(self.color, style: self.pathStyle)
		}
	}
}

extension Line: Identifiable {
	public var id: String {
		UUID().uuidString
	}
}

extension Line: Equatable {
	public static func == (lhs: Line, rhs: Line) -> Bool {
		lhs.id == rhs.id
	}
}

struct ChartLine_Previews: PreviewProvider {
	static var previews: some View {
		let data: [Point] = [
			.init(x: 0, y: 0),
			.init(x: 1, y: 3),
			.init(x: 2, y: 1),
			.init(x: 3, y: 2),
			.init(x: 4, y: 4)
		]
		let data2: [Point] = [
			.init(x: 1, y: 3),
			.init(x: 2, y: 1),
			.init(x: 3, y: 2),
			.init(x: 4, y: 4)
		]
		
		Group {
			Line(points: data, label: "Test")
			Line(points: data2, label: "Test")
//			Line(points: data2, label: "Test", style: StrokeStyle(dash: [2.0]))
			Line(points: data, label: "Test", color: Color.red)
			Line(points: data, label: "Test", curvedLine: true)
			Line(points: data, label: "Test", pointsOnly: true)
		}
		.frame(width: 300, height: 130)
		.previewLayout(PreviewLayout.sizeThatFits)
		.padding()
	}
}
