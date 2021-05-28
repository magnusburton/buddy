//
//  HealthTools.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-15.
//

import Foundation
import HealthKit

struct HealthTools {
	
	// https://www.mayoclinic.org/healthy-lifestyle/fitness/in-depth/exercise-intensity/art-20046887
	static func getMaxHR(age: Int) -> Double {
		return Double(220 - age)
	}
	
	// https://www.verywellfit.com/resting-heart-rate-3432632
	
	enum FitnessLevels {
		case Undetermined
		case Poor
		case Average
		case Good
		case Excellent
		case Athlete
	}
	
	static func getFitnessLevel(age: Int, gender: Int, rhr: Int) -> FitnessLevels {
		var rhrLimits: Array<Int>
		
		if gender == HKBiologicalSex.male.rawValue {
			switch age {
				case 0...17:
					return FitnessLevels.Undetermined
				case 18...25:
					rhrLimits = [55, 61, 65, 82]
				case 26...35:
					rhrLimits = [54, 61, 65, 82]
				case 36...45:
					rhrLimits = [56, 62, 66, 83]
				case 46...55:
					rhrLimits = [57, 63, 67, 84]
				case 56...65:
					rhrLimits = [56, 61, 67, 82]
				default:
					rhrLimits = [55, 61, 65, 80]
			}
		} else if gender == HKBiologicalSex.female.rawValue {
			switch age {
				case 0...17:
					return FitnessLevels.Undetermined
				case 18...25:
					rhrLimits = [60, 65, 69, 85]
				case 26...35:
					rhrLimits = [59, 64, 68, 83]
				case 36...45:
					rhrLimits = [59, 64, 69, 85]
				case 46...55:
					rhrLimits = [60, 65, 69, 84]
				case 56...65:
					rhrLimits = [59, 64, 68, 84]
				default:
					rhrLimits = [59, 64, 68, 84]
			}
		} else {
			return FitnessLevels.Undetermined
		}
		
		if rhr <= rhrLimits[0] {
			return FitnessLevels.Athlete
		} else if rhr <= rhrLimits[1] {
			return FitnessLevels.Excellent
		} else if rhr <= rhrLimits[2] {
			return FitnessLevels.Good
		} else if rhr <= rhrLimits[3] {
			return FitnessLevels.Average
		} else {
			return FitnessLevels.Poor
		}
	}
	
	// https://www.runnersworld.com/beginner/a20812270/should-i-do-heart-rate-training/
	
	enum HeartRateZones {
		case undetermined
		case endurance
		case moderate
		case tempo
		case threshold
		case anaerobic
	}
	
	static func getHeartRateZone(maxHR: Double, heartRate: Double) -> HeartRateZones {
		if heartRate <= maxHR*0.6 {
			return HeartRateZones.endurance
		} else if heartRate <= maxHR*0.7 {
			return HeartRateZones.moderate
		} else if heartRate <= maxHR*0.8 {
			return HeartRateZones.tempo
		} else if heartRate <= maxHR*0.9 {
			return HeartRateZones.threshold
		} else if heartRate <= maxHR*1.1 {
			return HeartRateZones.anaerobic
		}
		
		return HeartRateZones.undetermined
	}
	
	// Distance splits
	
	struct WorkoutDistanceSplit: Identifiable {
		var id = UUID()
		var sample: HKQuantity
		var distanceUnit: HKUnit
		var distance: HKQuantity
		var fastest: Bool = false
		var slowest: Bool = false
	}
	
	static func getSplits(samples: [HKQuantitySample], unit: HKUnit = HKUnit.meterUnit(with: .kilo)) -> [WorkoutDistanceSplit] {
		var splits: [TimeInterval] = []
		var distance: [HKQuantity] = []
		let limitDistance: Double = 1
		var countedDistance: Double = 0
		var startDate = samples[0].startDate
		let lastIndex: Int = samples.count - 1
		
		for (index, sample) in samples.enumerated() {
			let sampleDistance = sample.quantity.doubleValue(for: unit)
			
			if countedDistance + sampleDistance <= limitDistance {
				countedDistance += sampleDistance
				
				if index == lastIndex {
					let endDate: Date = sample.endDate
					
					let duration = DateInterval(start: startDate, end: endDate).duration
					let pace: TimeInterval = duration / countedDistance
					
					splits.append(pace)
					distance.append(HKQuantity(unit: unit, doubleValue: countedDistance))
				}
			} else {
				let distanceRemaining = limitDistance - countedDistance
				let percent = distanceRemaining / sampleDistance
				
				let sampleDuration = DateInterval(start: sample.startDate, end: sample.endDate).duration
				let remainingDuration: TimeInterval = percent * sampleDuration
				let endDate: Date = sample.startDate.addingTimeInterval(remainingDuration)
				
				if endDate > sample.endDate {
					print("Error during split calculation with sample: ", sample)
					return []
				}
				
				let pace = DateInterval(start: startDate, end: endDate).duration
				
				splits.append(pace)
				distance.append(HKQuantity(unit: unit, doubleValue: limitDistance))
				
				let nextDistance = sampleDistance - distanceRemaining
				startDate = endDate
				countedDistance = nextDistance
				
				if index == lastIndex {
					let endDate: Date = sample.endDate
					
					let duration = DateInterval(start: startDate, end: endDate).duration
					let pace: TimeInterval = duration / countedDistance
					
					splits.append(pace)
					distance.append(HKQuantity(unit: unit, doubleValue: countedDistance))
				}
			}
		}
		
		var formattedSplits: [WorkoutDistanceSplit] = []
		let slowest = splits.max()
		let fastest = splits.min()
		
		for (index, split) in splits.enumerated() {
			let splitData = WorkoutDistanceSplit(
				sample: HKQuantity(unit: HKUnit.second().unitDivided(by: unit), doubleValue: split),
				distanceUnit: unit,
				distance: distance[index],
				fastest: split == fastest,
				slowest: split == slowest)
			formattedSplits.append(splitData)
		}
		
		return formattedSplits
	}
}