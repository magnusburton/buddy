//
//  Insights.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-16.
//

import Foundation
import HealthKit

extension HealthManager {
	enum InsightType: CaseIterable {
		/// Compares yesterday's average with the previous four week's weekday averages
		case weekdayComparison
		/// Compare past 7 days with previous 7 days
		case twoWeekComparison
		/// Compares weekend's average with previous five weekday's average
		case weekendWeekComparison
		/// Compare past 28 days with previous 28 days
		case twoMonthComparison
	}

	struct Insight: Identifiable {
		var id = UUID()
		var type: InsightType
		var healthType: DataType
		/// The results of the given health data type `healthType` and the type of insights made `type`
		var results: InsightResult?
		/// Explaination of the insight and how to improve/maintain it
		var details: String?

		mutating func setResults(_ results: InsightResult) {
			self.results = results
			generateDetails()
		}
	}

	/// Results for a generated `Insight`which contains information of its results for display
	struct InsightResult: Equatable {
		/// If the results are significant and useable, not significant and useless or not determined
		var results: Results
		/// Noting `positive` or `negative` change
		var change: ResultsKind?
		/// Optional `Line` to be shown in insights card
		var line: Line?
		/// Metadata for the result, used for debugging
		var metadata: [String: Any] = [:]
		/// Insight generated on `Date`
		var generated = Date()

		enum Results {
			case undetermined
			case insignificant
			case significant
		}
		enum ResultsKind {
			case up
			case down
		}

		static func == (lhs: InsightResult, rhs: InsightResult) -> Bool {
			return
				lhs.results == rhs.results &&
				lhs.change == rhs.change
		}
	}

	static let possibleInsights: [DataType: [InsightType]] = [
		.bodyFat: [.twoWeekComparison, .twoMonthComparison, .weekdayComparison],
		.hrv: [.twoWeekComparison, .twoMonthComparison, .weekendWeekComparison],
		.rhr: [.twoMonthComparison, .twoWeekComparison, .weekendWeekComparison]
	]

	func generateInsights() {
		for insight in InsightType.allCases {
			for type in DataType.allCases {
				if let val = HealthManager.possibleInsights[type] {
					if !val.contains(insight) {
						continue
					}
				}

				// The insight for the given type is not forbidden, continue generating insight!
				generateInsight(insight, type: type) { results in
					var insight = Insight(type: insight, healthType: type, results: results)
					insight.generateDetails()
					
					if results.results == .significant {
						DispatchQueue.main.async {
							self.insights.append(insight)
						}
					}
				}
			}
		}
	}

	func generateInsight(_ insight: InsightType, type: DataType, completion: @escaping (InsightResult) -> Void) {
		guard let healthType = self.data[type] else {
			completion(.init(results: .undetermined))
			fatalError("*** No \(type) items to generate \(insight) insight on ***")
		}
		
		let items = healthType.items
		guard items.count > 0 else {
			completion(.init(results: .undetermined))
			fatalError("*** Zero \(type) items to generate \(insight) insight on ***")
		}

		let calendar = Calendar.current
		let now = Date()
		
		let unit = healthType.unit
		let threshold = healthType.threshold
		let identifier = healthType.identifier
		guard let sampleType = HKQuantityType.quantityType(forIdentifier: identifier) else {
			completion(.init(results: .undetermined))
			fatalError("*** Couldn't get sample type for \(insight) insight of \(type) with identifier \(identifier) ***")
		}
		let label = healthType.label

		if insight == .weekdayComparison {
			guard let yesterday = calendar.date(byAdding: .day, value: -1, to: now) else {
				completion(.init(results: .undetermined))
				fatalError("*** Couldn't generate date for \(insight) insight of \(type) ***")
			}
			guard let previousMonthWeekday = calendar.date(byAdding: .day, value: -7*4, to: yesterday) else {
				completion(.init(results: .undetermined))
				fatalError("*** Couldn't generate date for \(insight) insight of \(type) ***")
			}

			let weekday = calendar.component(.weekday, from: previousMonthWeekday)
			guard weekday == calendar.component(.weekday, from: yesterday) else {
				completion(.init(results: .undetermined))
				fatalError("*** Not same weekday for \(insight) insight of \(type) ***")
			}

			let interval = DateInterval(start: previousMonthWeekday.startOfDay, end: calendar.startOfDay(for: yesterday))
			/// Return matching weekdays in previous 28 days
			let pastWeekdays = items.filter { calendar.component(.weekday, from: $0.endDate) == weekday && interval.contains($0.endDate) }
			let yesterdayItems = items.filter { calendar.isDateInYesterday($0.endDate) }

			let averagePastMonth = pastWeekdays.average(unit: unit)
			let averageYesterday = yesterdayItems.average(unit: unit)

			let ratio = averageYesterday / averagePastMonth

			let thresholdMinimum = 1 - threshold
			let thresholdMaximum = 1 + threshold

			if ratio >= thresholdMaximum || ratio <= thresholdMinimum {
				var dailyAverages = pastWeekdays.average(by: [.day, .year, .month], type: sampleType, unit: unit)
				dailyAverages.append(contentsOf: yesterdayItems.average(by: [.day, .year, .month], type: sampleType, unit: unit))

				let points: [Point] = dailyAverages.map { Point(sample: $0, unit: unit) }

				let line = Line(points: points, label: label)

				completion(.init(results: .significant, change: ratio > 1 ? .up : .down, line: line, metadata: [
					"averagePastMonth": averagePastMonth,
					"averageYesterday": averageYesterday,
					"ratio": ratio,
					"threshold": threshold
				]))
			} else {
				completion(.init(results: .insignificant, change: ratio > 1 ? .up : .down, metadata: [
					"averagePastMonth": averagePastMonth,
					"averageYesterday": averageYesterday,
					"ratio": ratio,
					"threshold": threshold
				]))
			}
		} else if insight == .weekendWeekComparison {
			guard let yesterday = calendar.date(byAdding: .day, value: -1, to: now) else {
				completion(.init(results: .undetermined))
				fatalError("*** Couldn't generate date for \(insight) insight of \(type) ***")
			}

			if calendar.component(.weekday, from: yesterday) != 1 /* 1 = Sunday */ {
				completion(.init(results: .undetermined))
			}

			guard let saturday = calendar.date(byAdding: .day, value: -1, to: now) else {
				completion(.init(results: .undetermined))
				fatalError("*** Couldn't generate date for \(insight) insight of \(type) ***")
			}

			let weekendInterval = DateInterval(start: saturday.startOfDay, end: calendar.startOfDay(for: now))

			guard let monday = calendar.date(byAdding: .day, value: -5, to: now) else {
				completion(.init(results: .undetermined))
				fatalError("*** Couldn't generate date for \(insight) insight of \(type) ***")
			}

			let weekInterval = DateInterval(start: monday.startOfDay, end: calendar.startOfDay(for: saturday))

			let pastWeekend = items.filter { weekendInterval.contains($0.endDate) }
			let pastWeek = items.filter { weekInterval.contains($0.endDate) }

			let averageWeekend = pastWeekend.average(unit: unit)
			let averageWeek = pastWeek.average(unit: unit)

			let ratio = averageWeek / averageWeekend

			let thresholdMinimum = 1 - threshold
			let thresholdMaximum = 1 + threshold

			if ratio >= thresholdMaximum || ratio <= thresholdMinimum {
				var dailyAverages = pastWeek.average(by: [.day, .year, .month], type: sampleType, unit: unit)
				dailyAverages.append(contentsOf: pastWeekend.average(by: [.day, .year, .month], type: sampleType, unit: unit))

				let points: [Point] = dailyAverages.map { Point(sample: $0, unit: unit) }

				let line = Line(points: points, label: label)

				completion(.init(results: .significant, change: ratio > 1 ? .up : .down, line: line, metadata: [
					"averageWeekend": averageWeekend,
					"averageWeek": averageWeek,
					"ratio": ratio,
					"threshold": threshold
				]))
			} else {
				completion(.init(results: .insignificant, change: ratio > 1 ? .up : .down, metadata: [
					"averageWeekend": averageWeekend,
					"averageWeek": averageWeek,
					"ratio": ratio,
					"threshold": threshold
				]))
			}
		} else if insight == .twoWeekComparison {
			let endPeriodTwo = now.startOfDay
			
			guard let previousPeriod = calendar.date(byAdding: .day, value: -7, to: now) else {
				completion(.init(results: .undetermined))
				fatalError("*** Couldn't generate date for \(insight) insight of \(type) ***")
			}
			let endPeriodOne = calendar.startOfDay(for: previousPeriod)
			
			guard let previousSecondPeriod = calendar.date(byAdding: .day, value: -2*7, to: now) else {
				completion(.init(results: .undetermined))
				fatalError("*** Couldn't generate date for \(insight) insight of \(type) ***")
			}
			let startPeriodOne = calendar.startOfDay(for: previousSecondPeriod)
			
			let firstPeriod = DateInterval(start: startPeriodOne, end: endPeriodOne)
			let secondPeriod = DateInterval(start: endPeriodOne, end: endPeriodTwo)
			
			let firstPeriodItems = items.filter { firstPeriod.contains($0.endDate) }
			let secondPeriodItems = items.filter { secondPeriod.contains($0.endDate) }
			
			let firstPeriodAvg = firstPeriodItems.average(unit: unit)
			let secondPeriodAvg = secondPeriodItems.average(unit: unit)
			
			let ratio = secondPeriodAvg / firstPeriodAvg
			
			let thresholdMinimum = 1 - threshold
			let thresholdMaximum = 1 + threshold
			
			if ratio >= thresholdMaximum || ratio <= thresholdMinimum {
				var dailyAverages = firstPeriodItems.average(by: [.day, .year, .month], type: sampleType, unit: unit)
				dailyAverages.append(contentsOf: secondPeriodItems.average(by: [.day, .year, .month], type: sampleType, unit: unit))
				
				let points: [Point] = dailyAverages.map { Point(sample: $0, unit: unit) }
				
				let line = Line(points: points, label: label)
				
				completion(.init(results: .significant, change: ratio > 1 ? .up : .down, line: line, metadata: [
					"firstPeriodAvg": firstPeriodAvg,
					"secondPeriodAvg": secondPeriodAvg,
					"ratio": ratio,
					"threshold": threshold
				]))
			} else {
				completion(.init(results: .insignificant, change: ratio > 1 ? .up : .down, metadata: [
					"firstPeriodAvg": firstPeriodAvg,
					"secondPeriodAvg": secondPeriodAvg,
					"ratio": ratio,
					"threshold": threshold
				]))
			}
		} else if insight == .twoMonthComparison {
			let endPeriodTwo = calendar.startOfDay(for: now)
			
			guard let previousPeriod = calendar.date(byAdding: .day, value: -28, to: now) else {
				completion(.init(results: .undetermined))
				fatalError("*** Couldn't generate date for \(insight) insight of \(type) ***")
			}
			let endPeriodOne = calendar.startOfDay(for: previousPeriod)
			
			guard let previousSecondPeriod = calendar.date(byAdding: .day, value: -2*28, to: now) else {
				completion(.init(results: .undetermined))
				fatalError("*** Couldn't generate date for \(insight) insight of \(type) ***")
			}
			let startPeriodOne = calendar.startOfDay(for: previousSecondPeriod)
			
			let firstPeriod = DateInterval(start: startPeriodOne, end: endPeriodOne)
			let secondPeriod = DateInterval(start: endPeriodOne, end: endPeriodTwo)
			
			let firstPeriodItems = items.filter { firstPeriod.contains($0.endDate) }
			let secondPeriodItems = items.filter { secondPeriod.contains($0.endDate) }
			
			let firstPeriodAvg = firstPeriodItems.average(unit: unit)
			let secondPeriodAvg = secondPeriodItems.average(unit: unit)
			
			let ratio = secondPeriodAvg / firstPeriodAvg
			
			let thresholdMinimum = 1 - threshold
			let thresholdMaximum = 1 + threshold
			
			if ratio >= thresholdMaximum || ratio <= thresholdMinimum {
				var dailyAverages = firstPeriodItems.average(by: [.day, .year, .month], type: sampleType, unit: unit)
				dailyAverages.append(contentsOf: secondPeriodItems.average(by: [.day, .year, .month], type: sampleType, unit: unit))
				
				let points: [Point] = dailyAverages.map { Point(sample: $0, unit: unit) }
				
				let line = Line(points: points, label: label)
				
				completion(.init(results: .significant, change: ratio > 1 ? .up : .down, line: line, metadata: [
					"firstPeriodAvg": firstPeriodAvg,
					"secondPeriodAvg": secondPeriodAvg,
					"ratio": ratio,
					"threshold": threshold
				]))
			} else {
				completion(.init(results: .insignificant, change: ratio > 1 ? .up : .down, metadata: [
					"firstPeriodAvg": firstPeriodAvg,
					"secondPeriodAvg": secondPeriodAvg,
					"ratio": ratio,
					"threshold": threshold
				]))
			}
		}
	}
}
