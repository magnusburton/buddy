//
//  ChartGridView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-05.
//

import Foundation
import SwiftUI

/// Grid to be displayed in a line chart
public struct Grid: View {
	@Environment(\.chartStyle) var chartStyle
	
	public let xCount: Int
	public let yCount: Int
	
	private var xNiceMax: Double = 0
	private var xNiceMin: Double = 0
	private var yNiceMax: Double = 0
	private var yNiceMin: Double = 0
	
	public var isTimeline: Bool = false
	
	private var yMultiplier: Double = 1
	
	init(x: Int, y: Int) {
		self.xCount = x
		self.yCount = y
	}
	
	init(line: Line, xCount: Int? = nil, yCount: Int? = nil) {
		if line.count < 2 {
			self.xCount = 0
			self.yCount = 0
			return
		}
		
		let max = line.max
		let min = line.min
		
		let first = line.first
		let last = line.last
		
		self.yMultiplier = line.multiplier
		self.isTimeline = line.isTimeline
		
		let xAxis = Grid.calculateAxis(min: first.x, max: last.x)
		let yAxis = Grid.calculateAxis(min: min.y, max: max.y)
		
//		self.xNiceMax = xAxis.max
//		self.xNiceMin = xAxis.min
		self.xNiceMax = last.x
		self.xNiceMin = first.x
		
		self.yNiceMax = yAxis.max
		self.yNiceMin = yAxis.min
		
		if let strictXCount = xCount {
			self.xCount = strictXCount
		} else {
			self.xCount = xAxis.count
		}
		if let strictYCount = yCount {
			self.yCount = strictYCount
		} else {
			self.yCount = yAxis.count
		}
	}
	
	init(lines: [Line], xCount: Int? = nil, yCount: Int? = nil) {
		if lines.count < 1 {
			fatalError("Array must have at least one line.")
		}
		
		let highestCount = lines.max { a, b in a.count < b.count }!.count
		if highestCount < 2 {
			self.xCount = 0
			self.yCount = 0
			return
		}
		
		if lines.contains(where: { $0.isTimeline }) {
			guard lines.allSatisfy({ $0.isTimeline }) else {
				fatalError("*** Varying types of lines in chart. ***")
			}
			self.isTimeline = true
		}
		
		let max = lines.max { a, b in a.max < b.max }!.max
		let min = lines.min { a, b in a.min < b.min }!.min
		
		let first = lines.min { a, b in a.first.x < b.first.x }!.first
		let last = lines.max { a, b in a.last.x < b.last.x }!.last
		
		let xAxis = Grid.calculateAxis(min: first.x, max: last.x)
		let yAxis = Grid.calculateAxis(min: min.y, max: max.y)
		
		self.yMultiplier = lines.first!.multiplier
		
//		self.xNiceMax = xAxis.max
//		self.xNiceMin = xAxis.min
		self.xNiceMax = last.x
		self.xNiceMin = first.x
		
		self.yNiceMax = yAxis.max
		self.yNiceMin = yAxis.min
		
		if let strictXCount = xCount {
			self.xCount = strictXCount
		} else {
			self.xCount = xAxis.count
		}
		if let strictYCount = yCount {
			self.yCount = strictYCount
		} else {
			self.yCount = yAxis.count
		}
	}
	
	struct AxisData {
		let range: Double
		let spacing: Double
		let min: Double
		let max: Double
		let count: Int
	}
	
	private var style: LineChartStyle {
		(chartStyle as? LineChartStyle) ?? .init()
	}
	
	static func calculateAxis(min: Double, max: Double) -> AxisData {
		let maxTicks: Int = 5
		
		let range = niceNum(max - min, round: false)
		let tickSpacing = niceNum(range / Double((maxTicks - 1)), round: true)
		let niceMin = floor(min / tickSpacing) * tickSpacing
		let niceMax = ceil(max / tickSpacing) * tickSpacing
		
		var unroundedCount = (niceMax - niceMin) / tickSpacing
		
		if unroundedCount.isInfinite || unroundedCount.isNaN {
			unroundedCount = 1
		}
		let count = Int(unroundedCount) - 1
		
		return .init(range: range, spacing: tickSpacing, min: niceMin, max: niceMax, count: count)
	}
	
	static func niceNum(_ range: Double, round: Bool) -> Double {
		let exponent = floor(log10(range))
		let fraction = range / pow(10, exponent)
		let niceFraction: Double
		
		if round {
			if fraction <= 1.5 {
				niceFraction = 1
			} else if fraction <= 3 {
				niceFraction = 2
			} else if fraction <= 7 {
				niceFraction = 5
			} else {
				niceFraction = 10
			}
		} else {
			if fraction <= 1 {
				niceFraction = 1
			} else if fraction <= 2 {
				niceFraction = 2
			} else if fraction <= 5 {
				niceFraction = 5
			} else {
				niceFraction = 10
			}
		}
		
		return niceFraction * pow(10, exponent)
	}
	
	public var axisData: (xMax: Double, xMin: Double, xCount: Int, yMax: Double, yMin: Double, yCount: Int, yMultiplier: Double) {
		
		return (xMax: xNiceMax,
				xMin: xNiceMin,
				xCount: self.xCount,
				yMax: yNiceMax,
				yMin: yNiceMin,
				yCount: self.yCount,
				yMultiplier: self.yMultiplier)
	}
	
	public var body: some View {
		GeometryReader { geometry in
			Path { path in
				let xStepWidth = geometry.size.width / CGFloat(xCount)
				let yStepWidth = geometry.size.height / CGFloat(yCount)
				
				// Y axis lines
				(0...self.yCount).forEach { index in
					let y = CGFloat(index) * yStepWidth
					path.move(to: .init(x: 0, y: y))
					path.addLine(to: .init(x: geometry.size.width, y: y))
				}
				
				// X axis lines
				(0...self.xCount).forEach { index in
					let x = CGFloat(index) * xStepWidth
					path.move(to: .init(x: x, y: 0))
					path.addLine(to: .init(x: x, y: geometry.size.height))
				}
			}
			.stroke(style.showGrid ? Color.secondary : .clear)
		}
	}
}

struct ChartGrid_Previews: PreviewProvider {
	static var previews: some View {
		let data: Line = Line(points: [
			.init(x: 1, y: 8),
			.init(x: 2, y: 2),
			.init(x: 3, y: 6),
			.init(x: 4, y: 12),
			.init(x: 5, y: 7),
			.init(x: 6, y: 11),
			.init(x: 7, y: 7),
			.init(x: 8, y: 6)
		], label: "Test", color: .red)
		let data2: Line = Line(points: [
			.init(x: 1, y: 8),
			.init(x: 2, y: 2),
			.init(x: 3, y: 6),
			.init(x: 4, y: 12)
		], label: "Test", color: .red)
		
		Group {
			Grid(line: data)
			Grid(x: 5, y: 5)
			Grid(line: data2)
			Grid(x: 4, y: 8)
		}
		.frame(width: 300, height: 160)
		.previewLayout(PreviewLayout.sizeThatFits)
		.padding()
	}
}
