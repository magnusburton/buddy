//
//  ChartIndicatorView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-05.
//

import SwiftUI

struct ChartIndicator: View {
	var body: some View {
		ZStack{
			Circle()
				.fill(Color.accentColor)
			Circle()
				.stroke(Color.white, style: StrokeStyle(lineWidth: 3))
		}
		.frame(width: 14, height: 14)
		.shadow(color: .accentColor, radius: 4, x: 0, y: 3)
	}
}

struct ChartIndicator_Previews: PreviewProvider {
	static var previews: some View {
		ChartIndicator()
			.frame(width: 50, height: 50)
			.previewLayout(PreviewLayout.sizeThatFits)
			.padding()
	}
}
