//
//  PreviewTools.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-15.
//

import SwiftUI

struct ViewPreview<Value: View>: View {
	
	private let dynamicTypeSizes: [ContentSizeCategory] = [.extraSmall, .large, .extraExtraExtraLarge]
	
	/// Filter out "base" to prevent a duplicate preview.
	private let localizations = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }
	
	private let viewToPreview: Value
	
	init(_ viewToPreview: Value) {
		self.viewToPreview = viewToPreview
	}
	
	var body: some View {
		Group {
			self.viewToPreview
				.previewLayout(PreviewLayout.sizeThatFits)
				.padding()
				.previewDisplayName("Default preview 1")
			
			self.viewToPreview
				.previewLayout(PreviewLayout.sizeThatFits)
				.padding()
				.background(Color(.systemBackground))
				.environment(\.colorScheme, .dark)
				.previewDisplayName("Dark Mode")
			
			self.viewToPreview
				.previewLayout(PreviewLayout.sizeThatFits)
				.padding()
				.environment(\.layoutDirection, .rightToLeft)
				.previewDisplayName("Right to Left")
			
			ForEach(localizations, id: \.identifier) { locale in
				self.viewToPreview
					.previewLayout(PreviewLayout.sizeThatFits)
					.padding()
					.environment(\.locale, locale)
					.previewDisplayName(Locale.current.localizedString(forIdentifier: locale.identifier))
			}
			
			ForEach(dynamicTypeSizes, id: \.self) { sizeCategory in
				self.viewToPreview
					.previewLayout(PreviewLayout.sizeThatFits)
					.padding()
					.environment(\.sizeCategory, sizeCategory)
					.previewDisplayName("\(sizeCategory)")
			}
			
		}
	}
}
