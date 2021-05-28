//
//  InsightCardView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-17.
//

import SwiftUI
import CareKitUI

struct InsightCardView: View {
	@EnvironmentObject private var healthManager: HealthManager
	
	var insight: HealthManager.Insight
	@State var showMetadata = false
	
	init(_ insight: HealthManager.Insight) {
		self.insight = insight
		
		dump(self.insight.results?.metadata)
	}
	
	var type: HealthManager.DataType {
		self.insight.healthType
	}
	var foregroundColor: Color {
		guard let desiredSlope = healthManager.data[type]?.desiredSlope else { return .gray }
		guard let slope = self.insight.results?.change else { return .gray }
		
		if slope == desiredSlope {
			return .accentColor
		} else {
			return .secondary
		}
	}
	var systemName: String {
		guard let slope = self.insight.results?.change else { return "minus" }
		
		if slope == .up {
			return "arrow.up"
		} else {
			return "arrow.down"
		}
	}
	
	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					VStack(alignment: .leading, spacing: Constants.spacing) {
						Text("\(self.insight.healthType.rawValue)")
							.font(.headline.bold())
						if let details = self.insight.details {
							Text("\(details)")
								.font(.caption)
								.fontWeight(.medium)
						}
					}
					
					Spacer()
					
					Image(systemName: systemName)
						.font(.title.bold())
						.foregroundColor(self.foregroundColor)
				}
				
				if let line = self.insight.results?.line {
					Divider()
					
					LineChartView(line: line)
						.chartStyle(LineChartStyle(showLabels: true))
						.frame(height: 125)
				}
				
//				Divider()
//
//				HStack {
//					if let url = self.healthInfo.source.url {
//						Link(destination: url) {
//							Image(systemName: "link.circle.fill")
//							Text(self.healthInfo.source.title)
//						}
//					} else {
//						Image(systemName: "link.circle.fill")
//						Text(self.healthInfo.source.title)
//					}
//				}
//				.font(.footnote)
			}
			.padding()
		}
	}
}

struct InsightCardView_Previews: PreviewProvider {
    static var previews: some View {
		let insightUp = HealthManager.testInsights[0]
		let insightDown = HealthManager.testInsights[1]

		Group {
			ViewPreview(InsightCardView(insightUp))
			ViewPreview(InsightCardView(insightDown))
		}
		.frame(width: 350)
		.environmentObject(HealthManager())
    }
}
