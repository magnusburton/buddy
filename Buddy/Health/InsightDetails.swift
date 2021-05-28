//
//  InsightsText.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-18.
//

import Foundation
import HealthKit

extension HealthManager.Insight {
	mutating func generateDetails() {
		self.details = self.produceDetails()
	}
	
	func produceDetails() -> String? {
		let type = self.healthType
		let insight = self.type
		guard let results = self.results else {
			return "No insight could be generated at this moment."
		}
		
		if results.results == .undetermined {
			return "No insight could be generated at this moment."
		} else if results.results == .insignificant {
			// May wanna include this as a static metric
			return "The insights generated didn't make much sense or didn't show any large differences."
		}
		
		let df = DateFormatter()
		let calendar = Calendar.current
		
		let now = Date()
		guard let yesterday = calendar.date(byAdding: .day, value: -1, to: now) else {
			fatalError("*** Couldn't generate yesterday date ***")
		}
		
		// Resting Heart Rate
		if type == .rhr {
			if insight == .twoWeekComparison { // Compare past 7 days with previous 7 days
				if results.change == .up {
					return "Your average resting heart rate were higher during the past week compared to the week before. Make sure to breathe, maintain a good diet, and recover well from workouts."
				} else if results.change == .down {
					return "Your daily average resting heart rate decreased during the past seven days compared to the week before! Great job. Make sure you keep this up."
				}
			} else if insight == .weekdayComparison { // Compares yesterday's average with the previous four week's weekday averages
				df.setLocalizedDateFormatFromTemplate("EEEE")
				let weekday = df.string(from: yesterday)
				
				if results.change == .up {
					return "Your resting heart rate were higher yesterday than the previous four \(weekday)s. An elevated resting heart rate may be caused by stress or by consuming alcohol."
				} else if results.change == .down {
					return "You had a lower resting heart rate yesterday than the previous four \(weekday)s. A low resting heart rate may be a sign of good cardiovascular fitness and low stress."
				}
			} else if insight == .weekendWeekComparison { // Compares weekend's average with previous five weekday's average
				if results.change == .up {
					return "During the past weekend your average resting heart rate were significantly higher compared to the weekdays before that. An elevated resting heart rate may be caused by stress and meditation may help lowering it."
				} else if results.change == .down {
					return "Your RHR were lower this weekend compared to the weekdays before it. Well done on taking time out and getting enough rest!"
				}
			}
			// Heart Rate Variability
		} else if type == .hrv {
			if insight == .weekdayComparison { // Compares yesterday's average with the previous four week's weekday averages
				df.setLocalizedDateFormatFromTemplate("EEEE")
				let weekday = df.string(from: yesterday)
				
				if results.change == .up {
					return "Your average heart rate variability went up yesterday compared to the previous four \(weekday)s. A high HRV is a sign of low stress."
				} else if results.change == .down {
					return "Comparing your average heart rate variability to your average four previous \(weekday)s, yesterdays average is down significantly. Make sure you're meditating and getting enough rest to stay stress-free."
				}
			} else if insight == .weekendWeekComparison { // Compares weekend's average with previous five weekday's average
				if results.change == .up {
					return "During the past weekend your average heart rate variability were significantly higher compared to the weekdays before that. This is great because a high heart rate variability is a show of good rest and recovery from workouts, low stress, good diet, and more."
				} else if results.change == .down {
					return "Make sure to rest during the weekend and recover from your workouts. This will help increasing your heart rate variability. Your average HRV were down during the past weekend compared to the weekdays preceding it."
				}
			} else if insight == .twoWeekComparison { // Compare past 7 days with previous 7 days
				if results.change == .up {
					return "Your seven day-average were higher than the week before."
				} else if results.change == .down {
					return "Make sure to recover after your workouts and get enough sleep. Your average HRV decreased during the past seven days compared to the week before."
				}
			}
		} else if type == .bodyFat {
			if insight == .twoWeekComparison { // Compare past 7 days with previous 7 days
				if results.change == .up {
					return "Your average body fat percent increased during the past week compared to the week before. Make sure to get a good healthy diet, exercise, get your steps in, and avoid alcohol."
				} else if results.change == .down {
					return "The past seven days saw a decrease in body fat compared to the previous seven days. Well done on maintaining your diet, and exercising regularly! Keep this up by maintaining a good diet."
				}
			} else if insight == .twoMonthComparison { // Compare past 28 days with previous 28 days
				if results.change == .up {
					return "Your average body fat percent increased significantly during the past month compared to the month before. Make sure to get a good healthy diet, exercise, get your steps in, and avoid alcohol."
				} else if results.change == .down {
					return "The past 28 days saw a decrease in body fat compared to the previous month. Well done on maintaining your diet, and exercising regularly! Keep this up by maintaining a good diet."
				}
			}
		}
		
		
		return nil
	}
}


