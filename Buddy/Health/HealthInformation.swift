//
//  HealthInformation.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-17.
//

import Foundation

extension HealthManager {
	struct healthInfoSource {
		var title: String
		var url: URL?
	}
	
	static let availableHealthInformation: [DataType: healthInfoSource] = [
		.hrv: .init(
			title: "Harvard Health",
			url: URL(string: "https://www.health.harvard.edu/blog/heart-rate-variability-new-way-track-well-2017112212789")),
		.rhr: .init(
			title: "Harvard Health",
			url: URL(string: "https://www.health.harvard.edu/heart-health/what-your-heart-rate-is-telling-you")),
		.bodyFat: .init(
			title: "Harvard Health")
	]
}
