//
//  PersonalBestView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-04-18.
//

import SwiftUI

struct PersonalBestView: View {
	@EnvironmentObject private var workoutManager: WorkoutManager
	
	private var columns: [GridItem] = [
		GridItem(.flexible(), spacing: 5),
		GridItem(.flexible(), spacing: 5),
		GridItem(.flexible(), spacing: 5)
	]
	
    var body: some View {
		LazyVGrid(columns: columns, alignment: .center) {
			ForEach(WorkoutManager.allowedDistances) { distance in
				PersonalBestBadgeView(for: distance)
					.cornerRadius(Constants.cornerRadius)
			}
		}
    }
}

struct PersonalBestView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalBestView()
			.environmentObject(WorkoutManager())
    }
}
