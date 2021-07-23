//
//  LineChartView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-05.
//

import SwiftUI

struct LineChartView: View {
	@Environment(\.chartStyle) var chartStyle
	
	var lines: [Line]
	
	init(lines: [Line]) {
		self.lines = lines
	}
	
	init(line: Line) {
		self.lines = [line]
	}
	
	@State private var showIndicator: Bool = false
	@State private var touchLocation: CGPoint = .zero
	
	func getClosestDataPoint(to point: CGPoint, width: CGFloat, height: CGFloat) -> CGPoint {
		if self.lines.isEmpty {
			return .zero
		}
		
		var point = point
		let rect = CGRect(x: 0, y: 0, width: width, height: height)
		
		if !rect.contains(point) {
			point = rect.getClosestPointOnEdge(to: point)
		}
		
		return point
		
//		let step = Point(x: Double(width) / Double(self.diffXValue), y: Double(height) / Double(self.maxYValue))
//
//		let initialPoint: Point = self.points.first!
//
//		let initialX: Double = initialPoint.x * step.x - Double(width * self.minXValue / self.diffXValue)
//		let initialY: Double = Double(height) - (initialPoint.y * step.y)
//
//		path.move(to: Point(x: initialX, y: initialY).asCGPoint)
//
//		for pointIndex in 1..<points.count {
//			let point = self.points[pointIndex]
//
//			let x: Double = point.x * step.x - Double(width * self.minXValue / self.diffXValue)
//			let y: Double = Double(height) - (point.y * step.y)
//
//			path.addLine(to: Point(x: x, y: y).asCGPoint)
//		}
//
//
//
//		return .zero
	}
	
	func renderAndAdjustScale(for line: Line, size: CGSize) -> some View {
		let max = line.max
		let min = line.min
		let first = line.first
		let last = line.last
		
		let xInterval = last.x - first.x
		let yInterval = max.y - min.y
		
		let axisData = grid.axisData
		
		var scaleXInterval = axisData.xMax - axisData.xMin
		if scaleXInterval.isZero {
			scaleXInterval = .leastNonzeroMagnitude
		}
		
		var scaleYInterval = axisData.yMax - axisData.yMin
		if scaleYInterval.isZero {
			scaleYInterval = .leastNonzeroMagnitude
		}
		
//		let xScale = 1 * size.width
		let xScale = CGFloat(xInterval / scaleXInterval) * size.width
		let yScale = CGFloat(yInterval / scaleYInterval) * size.height
		
//		let xOffset: Double = 0
		let xOffset = (first.x - axisData.xMin) / scaleXInterval
		let yOffset = (axisData.yMax - max.y) / scaleYInterval
		
		let path = line.path
		return path
			.applying(CGAffineTransform(scaleX: xScale, y: -yScale))
			.offset(
				x: CGFloat(xOffset) * size.width,
				y: size.height - CGFloat(yOffset) * size.height)
			.stroke(line.color, style: line.pathStyle)
	}
	
	private var grid: Grid {
		return Grid(lines: self.lines, xCount: style.gridCount)
	}
	
	private var style: LineChartStyle {
		(chartStyle as? LineChartStyle) ?? .init()
	}
	
	private let formatter = DateFormatter()
	private var labels: [String] {
		let dateFormatter = style.dateFormatter
		
		formatter.setLocalizedDateFormatFromTemplate(dateFormatter)
		
		let allLabels: [String] = self.lines.flatMap {
			$0.points.compactMap {
				if let date = $0.date {
					return formatter.string(from: date)
				}
				return String(format: "%.0f", $0.x)
			}
		}
		
		return [
			allLabels.first!,
			allLabels.last!
		]
	}
	
	private var labelCount: Int {
		guard let labelCount = style.labelCount else {
			return grid.xCount
		}
		return labelCount
	}
	
	var body: some View {
		VStack {
			HStack {
				GeometryReader { geometry in
					ZStack {
						ForEach(self.lines) { line in
							renderAndAdjustScale(for: line, size: geometry.size)
						}
						.background(grid)
						
						if showIndicator {
							ChartIndicator()
								.position(self.touchLocation)
						}
						
						if style.showAxis {
							HStack {
								Spacer ()
								
								VStack(alignment: .trailing, spacing: 0) {
									Text("\(self.grid.axisData.yMax * self.grid.axisData.yMultiplier, specifier: "%.0f")")
										.padding(.top, 0)
									
									Spacer()
									
									Text("\(self.grid.axisData.yMin * self.grid.axisData.yMultiplier, specifier: "%.0f")")
										.padding(.bottom, 0)
								}
								.font(.footnote)
								.foregroundColor(.secondary)
								.padding(.trailing, 2)
							}
							.accessibilityHidden(true)
						}
					}
					.gesture(
						DragGesture().onChanged({ value in
							if style.enableTouch == false {
								return
							}
							//self.touchLocation = value.location
							self.touchLocation = self.getClosestDataPoint(to: value.location, width: geometry.size.width, height: geometry.size.height)
							self.showIndicator = true
							
							UISelectionFeedbackGenerator().selectionChanged()
						})
						.onEnded({ value in
							self.showIndicator = false
						})
					)
				}
			}
			
			if style.showLabels {
				HStack(alignment: .firstTextBaseline, spacing: 0) {
					ForEach(labels.indexed(), id: \.1.self) { index, label in
						if index != 0 {
							Spacer()
						}
						Text(label)
							.multilineTextAlignment(.center)
							.foregroundColor(.secondary)
							.font(.footnote)
					}
				}
				.padding([.top, .leading, .trailing], -4)
				.font(.footnote)
				.foregroundColor(.secondary)
				.accessibilityHidden(true)
			}
		}
	}
}

/// Type that defines a line chart style.
public struct LineChartStyle: ChartStyle {
	/// Bool value that controls whenever to show grid. Default is `true`.
	public let showGrid: Bool
	/// Bool value that controls whenever to show y-axis labels. Default is `true`.
	public let showAxis: Bool
	/// Bool value that controls whenever to show x-axis labels. Default is `false`.
	public let showLabels: Bool
	/// How to format eventual timeline labels on x-axis. Default is `cccccc`.
	public let dateFormatter: String
	/// The count of labels that should be shown on x-axis. Default is `all`.
	public let labelCount: Int?
	/// If touch is enabled on the chart to see details values. Default is `false`.
	public let enableTouch: Bool
	/// Add horizontal line. Default is `.none`.
	public let horizontalLine: CustomLineType?
	
	/// Creates new line chart style.
	init(
		showGrid: Bool = true,
		showAxis: Bool = true,
		showLabels: Bool = false,
		dateFormatter: String = "cccccc",
		labelCount: Int? = nil,
		enableTouch: Bool = false,
		horizontalLine: CustomLineType? = nil
	) {
		self.showGrid = showGrid
		self.showAxis = showAxis
		self.showLabels = showLabels
		self.dateFormatter = dateFormatter
		
		if labelCount != nil && labelCount! < 2 {
			self.labelCount = 2
		} else {
			self.labelCount = labelCount
		}
		
		self.enableTouch = enableTouch
		self.horizontalLine = horizontalLine
	}
	
	public var gridCount: Int? {
		if let count = self.labelCount {
			return count - 1
		}
		return nil
	}
	
	public enum CustomLineType {
		case average
		case max
		case min
		case custom(Double)
	}
}

struct LineChartView_Previews: PreviewProvider {
	static var previews: some View {
		let data2: Line = Line(points: [
			.init(x: 3, y: 2),
			.init(x: 4, y: 5),
			.init(x: 5, y: 3),
			.init(x: 6, y: 4)
		], label: "Test")
		let dateData: Line = Line(points: [
			.init(date: Date().addingTimeInterval(-3600*24*6), y: 5),
			.init(date: Date().addingTimeInterval(-3600*24*5), y: 7),
			.init(date: Date().addingTimeInterval(-3600*24*4), y: 7),
			.init(date: Date().addingTimeInterval(-3600*24*3), y: 3),
			.init(date: Date().addingTimeInterval(-3600*24*2), y: 11),
			.init(date: Date().addingTimeInterval(-3600*24*1), y: 8),
			.init(date: Date().addingTimeInterval(-3600*24*0), y: 4)
		], label: "Test")
		let data: Line = Line(points: [
			.init(x: 1, y: 9),
			.init(x: 2, y: 2),
			.init(x: 3, y: 9),
			.init(x: 4, y: 12),
			.init(x: 5, y: 7),
			.init(x: 6, y: 11),
			.init(x: 7, y: 15),
			.init(x: 8, y: 8)
		], label: "Test", color: .red)
		let data3: Line = Line(points: [
			.init(x: 0, y: 9),
			.init(x: 1, y: 8),
			.init(x: 2, y: 2),
			.init(x: 3, y: 6),
			.init(x: 4, y: 12),
			.init(x: 5, y: 7),
			.init(x: 6, y: 11),
			.init(x: 7, y: 7),
			.init(x: 8, y: 6),
			.init(x: 9, y: 6),
			.init(x: 10, y: 12),
			.init(x: 11, y: 7),
			.init(x: 12, y: 11),
			.init(x: 13, y: 7),
			.init(x: 14, y: 6),
			.init(x: 15, y: 7),
			.init(x: 16, y: 11),
			.init(x: 17, y: 7),
			.init(x: 18, y: 6),
			.init(x: 19, y: 6),
			.init(x: 20, y: 9),
			.init(x: 21, y: 8),
			.init(x: 22, y: 2),
			.init(x: 23, y: 6),
			.init(x: 24, y: 17),
			.init(x: 25, y: 7),
			.init(x: 26, y: 11),
			.init(x: 27, y: 7),
			.init(x: 28, y: 6),
			.init(x: 29, y: 6),
			.init(x: 30, y: 9),
			.init(x: 31, y: 8),
			.init(x: 32, y: 2),
			.init(x: 33, y: 6),
			.init(x: 34, y: 12),
			.init(x: 35, y: 7),
			.init(x: 36, y: 11),
			.init(x: 37, y: 7),
			.init(x: 38, y: 6),
			.init(x: 39, y: 6),
			.init(x: 40, y: 9),
			.init(x: 41, y: 8),
			.init(x: 42, y: 2),
			.init(x: 43, y: 6),
			.init(x: 44, y: 12),
			.init(x: 45, y: 7),
			.init(x: 46, y: 11),
			.init(x: 47, y: 7),
			.init(x: 48, y: 6),
			.init(x: 49, y: 6),
			.init(x: 50, y: 9),
			.init(x: 51, y: 8),
			.init(x: 52, y: 2),
			.init(x: 53, y: 6),
			.init(x: 54, y: 12),
			.init(x: 55, y: 7),
			.init(x: 56, y: 11),
			.init(x: 57, y: 7),
			.init(x: 58, y: 6),
			.init(x: 59, y: 6),
			.init(x: 60, y: 9),
			.init(x: 61, y: 8),
			.init(x: 62, y: 2),
			.init(x: 63, y: 6),
			.init(x: 64, y: 12),
			.init(x: 65, y: 7),
			.init(x: 66, y: 11),
			.init(x: 67, y: 7),
			.init(x: 68, y: 6),
			.init(x: 69, y: 6),
			.init(x: 70, y: 12),
			.init(x: 71, y: 7),
			.init(x: 72, y: 11),
			.init(x: 73, y: 7),
			.init(x: 74, y: 6),
			.init(x: 75, y: 7),
			.init(x: 76, y: 11),
			.init(x: 77, y: 7),
			.init(x: 78, y: 6),
			.init(x: 79, y: 6),
			.init(x: 80, y: 9),
			.init(x: 81, y: 8),
			.init(x: 82, y: 2),
			.init(x: 83, y: 6),
			.init(x: 84, y: 12),
			.init(x: 85, y: 7),
			.init(x: 86, y: 11),
			.init(x: 87, y: 7),
			.init(x: 88, y: 6),
			.init(x: 89, y: 6),
			.init(x: 90, y: 9),
			.init(x: 91, y: 8),
			.init(x: 92, y: 2),
			.init(x: 93, y: 6),
			.init(x: 94, y: 12),
			.init(x: 95, y: 7),
			.init(x: 96, y: 11),
			.init(x: 97, y: 7),
			.init(x: 98, y: 6),
			.init(x: 99, y: 6),
			.init(x: 100, y: 9),
			.init(x: 101, y: 8),
			.init(x: 102, y: 2),
			.init(x: 103, y: 6),
			.init(x: 104, y: 12),
			.init(x: 105, y: 7),
			.init(x: 106, y: 11),
			.init(x: 107, y: 7),
			.init(x: 108, y: 6),
			.init(x: 109, y: 6),
			.init(x: 110, y: 9),
			.init(x: 111, y: 8),
			.init(x: 112, y: 2),
			.init(x: 113, y: 6),
			.init(x: 114, y: 12),
			.init(x: 115, y: 7),
			.init(x: 116, y: 11),
			.init(x: 117, y: 7),
			.init(x: 118, y: 6),
			.init(x: 119, y: 6),
			.init(x: 120, y: 9),
			.init(x: 121, y: 8),
			.init(x: 122, y: 2),
			.init(x: 123, y: 6),
			.init(x: 124, y: 12),
			.init(x: 125, y: 7),
			.init(x: 126, y: 11),
			.init(x: 127, y: 7),
			.init(x: 128, y: 1),
			.init(x: 129, y: 18),
		], label: "Big data")
		
		Group {
			LineChartView(line: data3)
			LineChartView(line: data2)
				.chartStyle(LineChartStyle(showGrid: false, showAxis: true, showLabels: false))
			LineChartView(line: dateData)
				.chartStyle(LineChartStyle(showLabels: true, horizontalLine: .max))
			LineChartView(line: dateData)
				.chartStyle(LineChartStyle(showLabels: true, labelCount: 3))
			LineChartView(lines: [data, data2])
			LineChartView(line: data)
				.chartStyle(LineChartStyle(showLabels: true, enableTouch: true))
		}
		.frame(width: 300, height: 150)
		.previewLayout(PreviewLayout.sizeThatFits)
		.padding()
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		.environmentObject(UserData())
		.environmentObject(HealthKitManager())
		.environmentObject(WorkoutManager())
		.environmentObject(HealthManager())
	}
}
