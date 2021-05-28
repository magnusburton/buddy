//
//  HeartRateZonesSingleBarView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-15.
//

import SwiftUI

struct HeartRateZonesSingleBarView: View {
	var width: CGFloat
	var value: Double
	var max: Double
	var color: Color? = .blue
	
	init(width: CGFloat, value: Int, max: Int, color: Color? = .blue) {
		self.width = width
		self.value = Double(value)
		self.max = Double(max)
		self.color = color
	}
	
	var body: some View {
		if max > 0 {
			ZStack {
				Rectangle()
					.frame(width: width * CGFloat(value / max))
					.foregroundColor(color)
				if value/max > 0.10 {
					Text("\(value * 100 / max, specifier: "%.0f")%")
						.font(.caption)
						.scaledToFit()
						.foregroundColor(.primary)
				}
			}
			.isHidden(value <= 0)
		} else {
			EmptyView()
		}
	}
}

struct HeartRateZonesSingleBarView_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			ViewPreview(HeartRateZonesSingleBarView(width: 300, value: 210, max: 300))
			ViewPreview(HeartRateZonesSingleBarView(width: 300, value: 30, max: 300, color: .red))
		}
		.frame(height: 60)
    }
}
