//
//  PersonalBestBadgeView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-04-18.
//

import SwiftUI

struct PersonalBestBadgeView: View {
	@EnvironmentObject private var userData: UserData
	
	let personalBest: WorkoutManager.PersonalBestDistance
	let duration: DateInterval?
	
	init(for personalBest: WorkoutManager.PersonalBestDistance, duration: DateInterval? = nil) {
		self.personalBest = personalBest
		self.duration = duration
	}
	
	var paceString: String {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [.minute, .second]
		formatter.maximumUnitCount = 2
		
		let unit = userData.unitDistance
		let distanceDouble = personalBest.distance.doubleValue(for: unit)
		let pace: TimeInterval = duration?.duration ?? 0 / distanceDouble
		
		return formatter.string(from: pace) ?? "-:-"
	}
	
	var durationString: String {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .abbreviated
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.maximumUnitCount = 3
		
		let duration = duration?.duration
		return formatter.string(from: duration!) ?? "-"
	}
	
    var body: some View {
		VStack {
			Text("\(personalBest.label)")
				.font(.system(.title2, design: .rounded).bold())
				.multilineTextAlignment(.center)
			
			if duration == nil {
				Image(systemName: "lock")
					.font(.system(size: 30))
			} else {
				VStack(spacing: 2.0) {
					HStack {
						Image(systemName: "stopwatch")
						Text("\(durationString)")
					}
					HStack {
						Image(systemName: "speedometer")
						Text("\(paceString)\"")
					}
				}
			}
		}
		.padding()
    }
}

struct PersonalBestBadgeView_Previews: PreviewProvider {
    static var previews: some View {
		let best = WorkoutManager.allowedDistances[4]
		
		Group {
			ViewPreview(PersonalBestBadgeView(for: best))
			ViewPreview(PersonalBestBadgeView(for: best, duration: .init(start: Date(), duration: 1530)))
		}
		.environmentObject(UserData())
    }
}
