//
//  TouchesHandler.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-14.
//

import SwiftUI
import UIKit

//just a dummy
class MySwipeGesture: UISwipeGestureRecognizer {
	
	@objc func noop() {}
	
	init(target: Any?) {
		super.init(target: target, action: #selector(noop))
	}
}

//this delegate effectively disables the gesure
class MySwipeGestureDelegate: NSObject, UIGestureRecognizerDelegate {
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		false
	}
}

//and the overlay inspired by the answer from the link above
struct TouchesHandler: UIViewRepresentable {
	
	func makeUIView(context: UIViewRepresentableContext<TouchesHandler>) -> UIView {
		let view = UIView(frame: .zero)
		view.isUserInteractionEnabled = true
		view.addGestureRecognizer(context.coordinator.makeGesture())
		return view;
	}
	
	func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<TouchesHandler>) {
	}
	
	func makeCoordinator() -> Coordinator {
		return Coordinator()
	}
	
	class Coordinator {
		var delegate: UIGestureRecognizerDelegate = MySwipeGestureDelegate()
		func makeGesture() -> MySwipeGesture {
			delegate = MySwipeGestureDelegate()
			let gr = MySwipeGesture(target: self)
			gr.delegate = delegate
			return gr
		}
	}
	typealias UIViewType = UIView
}
