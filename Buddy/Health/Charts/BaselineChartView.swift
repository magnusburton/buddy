//
//  BaselineChartView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-19.
//

import SwiftUI

struct BaselineChartView: View {
	@EnvironmentObject private var healthManager: HealthManager
	
	var type: HealthManager.DataType
	
	init(for type: HealthManager.DataType) {
		self.type = type
	}
	
	var body: some View {
		LineChartView(line: healthManager.data[self.type]!.averageLine(by: Constants.movingAverage))
			.chartStyle(LineChartStyle())
			.frame(height: 125)
	}
}

struct BaselineChartView_Previews: PreviewProvider {
    static var previews: some View {
		ViewPreview(BaselineChartView(for: .hrv))
			.environmentObject(HealthManager())
    }
}
