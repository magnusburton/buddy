//
//  ComparisonBarChart.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-06-02.
//

import SwiftUI

struct ComparisonBarChart: View {
	var previousLabel: String
	var previousValue: Double
	var currentLabel: String
	var currentValue: Double
	var unit: String
	
	private let widthCoefficient: Double = 1.10
	private let textWarpThreshold: Double = 0.35
	var maxValue: Double {
		if previousValue > currentValue {
			return previousValue * widthCoefficient
		}
		return currentValue * widthCoefficient
	}
	
    var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				VStack(alignment: .leading, spacing: Constants.spacing) {
					HStack(alignment: .lastTextBaseline, spacing: Constants.spacing) {
						Text("\(previousValue, specifier: "%.0f")")
							.font(.title2.bold())
						Text(unit)
							.font(.footnote.bold())
							.foregroundColor(.secondary)
					}
					HStack(spacing: 5) {
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(.secondary)
							.frame(width: geometry.size.width * CGFloat(previousValue / maxValue), height: 25)
							.overlay(HStack {
								if previousValue / maxValue >= textWarpThreshold {
									Text(previousLabel)
										.font(.footnote.bold())
										.foregroundColor(.systemBackground)
										.scaledToFit()
										.minimumScaleFactor(0.5)
									Spacer()
								}
							}.padding([.leading], 7))
						
						if previousValue / maxValue < textWarpThreshold {
							Text(previousLabel)
								.font(.footnote.bold())
								.foregroundColor(.secondary)
						}
					}
				}
				
				VStack(alignment: .leading, spacing: Constants.spacing) {
					HStack(alignment: .lastTextBaseline, spacing: Constants.spacing) {
						Text("\(currentValue, specifier: "%.0f")")
							.font(.title2.bold())
						Text(unit)
							.font(.footnote.bold())
							.foregroundColor(.secondary)
					}
					HStack(spacing: 5) {
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(.accentColor)
							.frame(width: geometry.size.width * CGFloat(currentValue / maxValue), height: 25)
							.overlay(HStack {
								if currentValue / maxValue >= textWarpThreshold {
									Text(currentLabel)
										.font(.footnote.bold())
										.foregroundColor(.white)
										.scaledToFit()
									Spacer()
								}
							}.padding([.leading], 7))
						
						if currentValue / maxValue < textWarpThreshold {
							Text(currentLabel)
								.font(.footnote.bold())
								.foregroundColor(.accentColor)
						}
					}
				}
			}
		}
    }
}

struct ComparisonBarChart_Previews: PreviewProvider {
    static var previews: some View {
		ViewPreview(ComparisonBarChart(
			previousLabel: "Yesterday",
			previousValue: 2478,
			currentLabel: "Today",
			currentValue: 7492,
			unit: "steps"))
			.frame(width: 250, height: 175)
    }
}
