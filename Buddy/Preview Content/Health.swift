//
//  Health.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-17.
//

import Foundation
import HealthKit

extension HealthManager {
	static let _insightResultsPossible: [HealthManager.InsightResult] = [
		.init(results: .significant, change: .up),
		.init(results: .significant, change: .down),
		.init(results: .insignificant, change: .up),
		.init(results: .insignificant, change: .down),
		.init(results: .undetermined)
	]
	
	static let testInsights: [HealthManager.Insight] = HealthManager.DataType.allCases.flatMap { dataType in
		return HealthManager.InsightType.allCases.flatMap { insightType in
			return _insightResultsPossible.compactMap { result in
				return .init(type: insightType, healthType: dataType, results: result, details: "During the past weekend your average resting heart rate were significantly higher compared to the weekdays before that. An elevated resting heart rate may be caused by stress and meditation may help lowering it.")
			}
		}
	}
}
