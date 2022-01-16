//
//  Path+Extensions.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-11-06.
//

import SwiftUI

public extension Path {
    mutating func addLine(from p1: CGPoint, to p2: CGPoint) {
        self.move(to: p1)
        self.addLine(to: p2)
    }
}
