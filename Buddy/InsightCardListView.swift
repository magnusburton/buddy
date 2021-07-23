//
//  InsightCardListView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-06-03.
//

import SwiftUI
import CareKitUI

struct InsightCardListView: View {
	@EnvironmentObject private var userData: UserData
	@EnvironmentObject private var healthManager: HealthManager
	
	var body: some View {
		listView
	}
	
	@ViewBuilder
	var listView: some View {
		if healthManager.insights.isEmpty {
			emptyListView
		} else {
			objectsListView
		}
	}
	
	var emptyListView: some View {
		CardView {
			HStack(spacing: Constants.spacing*3) {
				Spacer()
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle())
				Text("insight.loading.text")
				Spacer()
			}
			.frame(height: 100)
			.padding()
		}
	}
	
	var objectsListView: some View {
		ForEach(healthManager.insights) { insight in
			InsightCardView(insight)
				.animation(.easeIn)
		}
	}
}

struct InsightCardListView_Previews: PreviewProvider {
    static var previews: some View {
        ViewPreview(InsightCardListView())
			.environmentObject(UserData())
			.environmentObject(HealthManager())
    }
}
