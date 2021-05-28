//
//  ConditionalTool.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import SwiftUI

extension View {
	@ViewBuilder
	func `if`<Transform: View>(
		_ condition: Bool,
		transform: (Self) -> Transform
	) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}
