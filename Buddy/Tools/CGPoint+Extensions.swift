//
//  CGPoint+Extensions.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-11-06.
//

import SwiftUI

public extension CGPoint {
    init(unitPoint: UnitPoint, in rect: CGRect) {
        self.init(
            x: rect.width * unitPoint.x,
            y: rect.height - (rect.height * unitPoint.y)
        )
    }
}
