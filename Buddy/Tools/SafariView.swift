//
//  SafariView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-21.
//

#if canImport(SafariServices)

import Foundation
import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
	
	private let url: URL
	
	init(url: URL) {
		self.url = url
	}
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
		let config = SFSafariViewController.Configuration()
		config.barCollapsingEnabled = true
		return SFSafariViewController(url: url, configuration: config)
	}
	
	func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}
#endif
