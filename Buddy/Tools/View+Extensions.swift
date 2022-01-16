//
//  View+Extensions.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-11-22.
//

import SwiftUI

extension View {
	public func foregroundGradient(colors: [Color]) -> some View {
		self.overlay(LinearGradient(gradient: .init(colors: colors),
									startPoint: .leading,
									endPoint: .trailing))
			.mask(self)
	}
	
	public func cardModifier() -> some View {
		self
			.modifier(CardModifier())
	}
}

private struct CardModifier: ViewModifier {
	
	private var cardShape: RoundedRectangle {
		RoundedRectangle(cornerRadius: 12, style: .continuous)
	}
	
	func body(content: Content) -> some View {
		content
			.clipShape(cardShape)
			.background(
				cardShape
					.foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
					.shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.15),
							radius: 8,
							x: 0,
							y: 2)
			)
	}
}
