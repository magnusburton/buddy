//
//  Color.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-27.
//

import SwiftUI
import UIKit

extension Color {
	static let systemBackground = Color(UIColor.systemBackground)
	static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
	static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
	
	var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
		#if canImport(UIKit)
		typealias NativeColor = UIColor
		#elseif canImport(AppKit)
		typealias NativeColor = NSColor
		#endif
		
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var o: CGFloat = 0
		
		guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
			return (0, 0, 0, 0)
		}
		return (r, g, b, o)
	}
	
	/// Lighten a color.
	///
	///     let color = Color(red: r, green: g, blue: b, alpha: a)
	///     let lighterColor: Color = color.lighten(by: 0.2)
	///
	/// - Parameter percentage: Percentage by which to lighten the color.
	/// - Returns: A lightened color.
	func lighten(by percentage: Double = 0.2) -> Color {
		let UIColor = UIColor(self)
		let newColor = UIColor.lighten(by: percentage)
		return Color(newColor)
	}
	
	/// Darken a color.
	///
	///     let color = Color(red: r, green: g, blue: b, alpha: a)
	///     let darkerColor: Color = color.darken(by: 0.2)
	///
	/// - Parameter percentage: Percentage by which to darken the color.
	/// - Returns: A darkened color.
	func darken(by percentage: Double = 0.2) -> Color {
		let UIColor = UIColor(self)
		let newColor = UIColor.darken(by: percentage)
		return Color(newColor)
	}
	
	func adjust(by percentage: Double = 20.0) -> Color {
		return Color(red: min(Double(self.components.red + percentage/100), 1.0),
					 green: min(Double(self.components.green + percentage/100), 1.0),
					 blue: min(Double(self.components.blue + percentage/100), 1.0),
					 opacity: Double(self.components.opacity))
	}
}

extension UIColor {
	func mix(with color: UIColor, amount: CGFloat) -> Self {
		var red1: CGFloat = 0
		var green1: CGFloat = 0
		var blue1: CGFloat = 0
		var alpha1: CGFloat = 0
		
		var red2: CGFloat = 0
		var green2: CGFloat = 0
		var blue2: CGFloat = 0
		var alpha2: CGFloat = 0
		
		getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
		color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
		
		return Self(
			red: red1 * CGFloat(1.0 - amount) + red2 * amount,
			green: green1 * CGFloat(1.0 - amount) + green2 * amount,
			blue: blue1 * CGFloat(1.0 - amount) + blue2 * amount,
			alpha: alpha1
		)
	}
	
	/// Lighten a color.
	///
	///     let color = UIColor(red: r, green: g, blue: b, alpha: a)
	///     let lighterColor: UIColor = color.lighten(by: 0.2)
	///
	/// - Parameter percentage: Percentage by which to lighten the color.
	/// - Returns: A lightened color.
	func lighten(by percentage: Double = 0.2) -> UIColor {
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		return UIColor(red: min(red + percentage, 1.0),
					   green: min(green + percentage, 1.0),
					   blue: min(blue + percentage, 1.0),
					   alpha: alpha)
	}
	
	/// Darken a color.
	///
	///     let color = UIColor(red: r, green: g, blue: b, alpha: a)
	///     let darkerColor: UIColor = color.darken(by: 0.2)
	///
	/// - Parameter percentage: Percentage by which to darken the color.
	/// - Returns: A darkened color.
	func darken(by percentage: Double = 0.2) -> UIColor {
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		return UIColor(red: max(red - percentage, 0),
					   green: max(green - percentage, 0),
					   blue: max(blue - percentage, 0),
					   alpha: alpha)
	}
}
