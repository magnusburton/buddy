//
//  OptionalBinding.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-14.
//

import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
	Binding(
		get: { lhs.wrappedValue ?? rhs },
		set: { lhs.wrappedValue = $0 }
	)
}
