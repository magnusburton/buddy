//
//  ChartStyle.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-25.
//

import SwiftUI

public protocol ChartStyle {
	var showGrid: Bool { get }
	var showLabels: Bool { get }
	var showAxis: Bool { get }
}

struct ChartStyleEnvironmentKey: EnvironmentKey {
	static var defaultValue: ChartStyle?
}

extension EnvironmentValues {
	var chartStyle: ChartStyle? {
		get { self[ChartStyleEnvironmentKey.self] }
		set { self[ChartStyleEnvironmentKey.self] = newValue }
	}
}

extension View {
	public func chartStyle(_ style: ChartStyle) -> some View {
		environment(\.chartStyle, style)
	}
}
