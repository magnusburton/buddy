//
//  HorizontalRangeChart.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-11-01.
//

import SwiftUI

fileprivate let capsuleHeight = 9.0
fileprivate let borderWidth = 4.0

struct HorizontalRangeChart: View {
    var value: Double
    var optimalRange: ClosedRange<Double>
    var showRange = false
    
    private let background = Color.secondary.opacity(0.5)
    private let optimal = Color.accentColor.opacity(0.5)
    
    var horizontalAlignment: HorizontalAlignment {
        if optimalRange.contains(value) {
            if optimalRange.lowerBound > 0 {
                return .center
            } else {
                return .leading
            }
        } else if value < optimalRange.lowerBound {
            return .leading
        } else if value > optimalRange.upperBound {
            return .trailing
        }
        return .center
    }
    
    var valuePercentage: Double {
        return (value-optimalRange.lowerBound)/(optimalRange.upperBound-optimalRange.lowerBound)
    }
    
    var body: some View {
        VStack(alignment: horizontalAlignment, spacing: 2) {
            Text(optimalRange.contains(value) ? "chart.range.inrange" : "chart.range.outofrange")
                .font(.caption2.bold())
            
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    if optimalRange.lowerBound > 0 {
                        Capsule()
                            .foregroundColor(value < optimalRange.lowerBound ? .yellow : background)
                            .frame(height: capsuleHeight)
                    }
                    
                    ZStack {
                        Capsule()
                            .foregroundColor(optimalRange.contains(value) ? optimal : background)
                            .frame(width: (optimalRange.lowerBound > 0 ? 0.5 : 0.75) * geometry.size.width,
                                   height: capsuleHeight)
                        
                        if optimalRange.contains(value) {
                            HorizontalRangeDotView()
                                .offset(x: optimalRange.lowerBound > 0 ? geometry.size.width*0.5*0.91*(valuePercentage-0.5) : geometry.size.width*0.34125*(-1 + 2*valuePercentage))
                        }
                    }
                    
                    Capsule()
                        .foregroundColor(value > optimalRange.upperBound ? .yellow : background)
                        .frame(height: capsuleHeight)
                }
                .flipsForRightToLeftLayoutDirection(false)
            }
        }
    }
}

struct HorizontalRangeChart_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewPreview(HorizontalRangeChart(
                value: 170,
                optimalRange: 120...220))
            ViewPreview(HorizontalRangeChart(
                value: 67,
                optimalRange: 61...100,
                showRange: true))
            ViewPreview(HorizontalRangeChart(
                value: 18,
                optimalRange: 0...59,
                showRange: true))
        }
        .frame(width: 150, height: 75)
    }
}

struct HorizontalRangeDotView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            Circle()
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .frame(width: capsuleHeight, height: capsuleHeight)
            Circle()
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: capsuleHeight-borderWidth, height: capsuleHeight-borderWidth)
        }
    }
}
