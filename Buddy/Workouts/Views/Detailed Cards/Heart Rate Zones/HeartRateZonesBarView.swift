//
//  HeartRateZonesView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-15.
//

import SwiftUI
import HealthKit

struct HeartRateZonesBarView: View {
	let data: [HKQuantitySample]
	private var totalCount: Int = 0
	private var zones: [HealthTools.HeartRateZones: Int] = [
		.undetermined: 0,
		.endurance: 0,
		.moderate: 0,
		.tempo: 0,
		.threshold: 0,
		.anaerobic: 0
	]
	
	init(data: [HKQuantitySample]) {
		self.data = data
		
		for sample in data {
			let age: Int = 24
			let maxHR: Double = HealthTools.getMaxHR(age: age)
			
			let heartRate: Double = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
			
			let zone = HealthTools.getHeartRateZone(maxHR: maxHR, heartRate: heartRate)
			
			self.zones[zone]! += 1
			self.totalCount += 1
		}
	}
	
	var body: some View {
		GeometryReader { geometry in
			HStack(spacing: 0.0) {
				Group {
					HeartRateZonesSingleBarView(width: geometry.size.width, value: zones[.undetermined] ?? 0, max: totalCount, color: .gray)
					HeartRateZonesSingleBarView(width: geometry.size.width, value: zones[.endurance] ?? 0, max: totalCount, color: .blue)
					HeartRateZonesSingleBarView(width: geometry.size.width, value: zones[.moderate] ?? 0, max: totalCount, color: .green)
					HeartRateZonesSingleBarView(width: geometry.size.width, value: zones[.tempo] ?? 0, max: totalCount, color: .yellow)
					HeartRateZonesSingleBarView(width: geometry.size.width, value: zones[.threshold] ?? 0, max: totalCount, color: .orange)
					HeartRateZonesSingleBarView(width: geometry.size.width, value: zones[.anaerobic] ?? 0, max: totalCount, color: .red)
				}
			}
		}
	}
}

struct HeartRateZonesView_Previews: PreviewProvider {
    static var previews: some View {
		ViewPreview(HeartRateZonesBarView(data: WorkoutManager.testHeartRate))
			.frame(height: 60)
    }
}
