//
//  WorkoutSplitsView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-07-13.
//

import SwiftUI
import HealthKit
import CareKitUI

struct WorkoutSplitsView: View {
	@ObservedObject var workout: WorkoutManager.Workout
	
	var splits: [HealthTools.WorkoutDistanceSplit] {
		workout.splits ?? []
	}
	
	private let fastestSplit: TimeInterval = 1.0
	private let widthOffset: CGFloat = 50
	
	var body: some View {
		CardView {
			VStack(alignment: .leading) {
				Text("Splits")
					.font(.headline)
					.bold()
//				detail?
//					.font(.caption)
//					.fontWeight(.medium)
				
				Divider()
				ForEach(Array(zip(splits.indices, splits)), id: \.0) { index, split in
					WorkoutSplitSingleView(split: split, index: index)
				}
			}
			.padding()
		}
	}
}

struct WorkoutSplitSingleView: View {
	@EnvironmentObject private var userData: UserData
	
	var split: HealthTools.WorkoutDistanceSplit
	var index: Int
	
	var distance: HKQuantity {
		split.distance
	}
	
	var distanceText: Text {
		let distance = split.distance.doubleValue(for: split.distanceUnit)
		if distance < 1 {
			return Text("\(distance, specifier: "%.2f")")
		} else {
			return Text("\(split.distanceUnit.unitString.uppercased()) \(index + 1)")
		}
	}
	
	var pace: String {
		let pace = split.sample.doubleValue(for: HKUnit.second().unitDivided(by: userData.unitDistance))
		let formatted = pace.format(units: [.minute, .second], style: .positional, limit: 2)
		return formatted ?? "--:--"
	}
	
	var body: some View {
		HStack {
			distanceText
			.font(.footnote)
			.foregroundColor(.secondary)
			
			Spacer()
			
			if split.fastest {
				Image(systemName: "crown.fill")
					.foregroundColor(.orange)
					.scaleEffect(0.6)
			}
			
			Text(pace)
				.font(.callout)
			
			//						Rectangle()
			//							.frame(width: geometry.size.width * CGFloat(data[index].sample.doubleValue(for: HKUnit.second().unitDivided(by: genericUnit)) / fastestSplit) - widthOffset, height: 20, alignment: .trailing)
			//							.foregroundColor(.accentColor)
		}
	}
}

struct WorkoutSplitsView_Previews: PreviewProvider {
    static var previews: some View {
		WorkoutSplitsView(workout: WorkoutManager.testWorkouts[0])
    }
}
