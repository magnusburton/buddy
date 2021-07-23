//
//  LoadingChartView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-07-15.
//

import SwiftUI

struct LoadingChartView: View {
    var body: some View {
		HStack(spacing: Constants.spacing*3) {
			Spacer()
			ProgressView()
				.progressViewStyle(CircularProgressViewStyle())
			Text("chart.loading.text")
			Spacer()
		}
    }
}

struct LoadingChartView_Previews: PreviewProvider {
    static var previews: some View {
        ViewPreview(LoadingChartView())
			.frame(height: 125)
    }
}
