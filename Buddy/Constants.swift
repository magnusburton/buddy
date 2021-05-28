//
//  Constants.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import UIKit
import SwiftUI

struct Constants {
	
	static let TabBarImages = [
		"heart.fill",
		"figure.walk.circle.fill"
	]
	
	static let TabBarNames = [
		LocalizedStringKey("Summary"),
		LocalizedStringKey("Workouts")
	]
	
	static let cornerRadius: CGFloat = 12.0
	static let spacing: CGFloat = 2.0
	static let padding: CGFloat = 10.0
	
	struct widget {
		
		static let padding: CGFloat = 12.0
		
	}
	
	/// Days of lag for the moving average charts
	static let movingAverage: Int = 7
	
}
