//
//  WorkoutDetailView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-07.
//

import SwiftUI
import HealthKit

func WorkoutDistanceDetailView(for distance: HKQuantity?, unit: HKUnit) -> Text {
	if distance != nil {
		return Text("\(distance!.doubleValue(for: unit), specifier: "%.2f") \(unit.unitString)")
	} else {
		return Text("-")
	}
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			ViewPreview(WorkoutDistanceDetailView(
				for:
					HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 5.02),
				unit:
					HKUnit.meterUnit(with: .kilo)
			))
			ViewPreview(WorkoutDistanceDetailView(
				for:
					HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: 5.02),
				unit:
					HKUnit.mile()
			))
		}
    }
}
