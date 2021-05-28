//
//  ProgressBarView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-04-26.
//

import SwiftUI

struct ProgressBarView: View {
	var progress: Double
	
	static let hue: Double = 0.92
	private let backgroundColor: Color = .secondary
	private let foregroundColor: Color = .accentColor
	
	init(progress: Double) {
		if progress > 1 {
			self.progress = 1
		} else if progress < 0 {
			self.progress = 0
		} else {
			self.progress = progress
		}
	}
	
	init(_ value: Double, of total: Double) {
		let division = value / total
		
		if division > 1 {
			self.progress = 1
		} else if division < 0 {
			self.progress = 0
		} else {
			self.progress = division
		}
	}
	
	var body: some View {
		ZStack {
			GeometryReader { geometry in
				Capsule()
					.foregroundColor(self.backgroundColor)
				
				Capsule()
					.frame(width: CGFloat(self.progress) * geometry.size.width)
					.foregroundColor(self.foregroundColor)
					.animation(.easeIn)
			}
		}
		.frame(height: 10)
	}
}

struct ProgressBarView_Previews: PreviewProvider {
	static var previews: some View {
		ViewPreview(ProgressBarView(progress: 0.80))
			.frame(height: 60)
	}
}
