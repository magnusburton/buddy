//
//  HiddenTool.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import SwiftUI

extension View {
	
	/// Hide or show the view based on a boolean value.
	///
	/// Example for visibility:
	/// ```
	/// Text("Label")
	///     .isHidden(true)
	/// ```
	///
	/// - Parameters:
	///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
	@ViewBuilder func isHidden(_ hidden: Bool) -> some View {
		if hidden {
			self.hidden()
		} else {
			self
		}
	}
}
