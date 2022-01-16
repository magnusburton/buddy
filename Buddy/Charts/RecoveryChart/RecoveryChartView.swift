//
//  RecoveryChartView.swift
//  Buddy
//
//  Created by Magnus Burton on 2022-01-03.
//

import SwiftUI
import HealthKit

struct RecoveryChartView: View {
	let line: Line
	
	init(line: Line) {
		if let startDate = line.first.date {
			self.startDate = startDate
		}
		
		self.line = line
	}
	
	private var startDate: Date = .now
	private var endDate: Date {
		startDate.addingTimeInterval(3*60)
	}
	
	private var max: Double {
		line.max.y
	}
	
	private var min: Double {
		line.min.y
	}
	
	private let dotSize = 5.0
	
	private let unit = HKUnit.count().unitDivided(by: .minute())
	
    var body: some View {
		VStack(spacing: 2) {
			ZStack {
				GridPattern(
					horizontalLines: 0,
					verticalLines: 4)
					.stroke(Color.secondary, style: .init(lineWidth: 0.5, lineCap: .round))
				
				HStack {
					Spacer()
					
					VStack {
						Text(max.formatted(.number.precision(.fractionLength(0))))
						
						Spacer()
						
						Text(min.formatted(.number.precision(.fractionLength(0))))
					}
					.font(.footnote)
					.foregroundColor(.secondary)
				}
				.padding(.trailing, 2)
				
				GeometryReader { geo in
					ForEach(self.line.points) { point in
						renderAndAdjustScale(for: point, in: self.line, size: geo.size)
					}
				}
			}
			
			HStack(alignment: .top) {
				Text(startDate.formatted(date: .omitted, time: .shortened))
				
				Spacer()
				
				Text("+1 min")
				
				Spacer()
				
				Text("+2 min")
				
				Spacer()
			}
			.foregroundColor(.secondary)
			.font(.footnote)
		}
    }
	
	private func renderAndAdjustScale(for point: Point, in line: Line, size: CGSize) -> some View {
		var scaleXInterval = endDate - startDate
		if scaleXInterval.isZero {
			scaleXInterval = .leastNonzeroMagnitude
		}
		
		var scaleYInterval = max - min
		if scaleYInterval.isZero {
			scaleYInterval = .leastNonzeroMagnitude
		}
		
		let xOffset = (point.x - startDate.timeIntervalSince1970) / scaleXInterval
		let yOffset = (max - point.y) / scaleYInterval
		
		return Circle()
			.frame(width: dotSize, height: dotSize, alignment: .center)
			.foregroundColor(.red)
			.cornerRadius(dotSize/2, antialiased: false)
			.position(
				x: xOffset * size.width,
				y: yOffset * size.height)
	}
}

struct RecoveryChartView_Previews: PreviewProvider {
    static var previews: some View {
		RecoveryChartView(line: Line(points: WorkoutManager.testHeartRate().asHealthSamples.points(unit: .count().unitDivided(by: .minute())), label: "HRR"))
			.previewLayout(.fixed(width: 350, height: 280))
			.padding()
    }
}
