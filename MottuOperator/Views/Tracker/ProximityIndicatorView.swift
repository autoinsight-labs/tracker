//
//  ProximityIndicatorView.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 29/09/25.
//

import SwiftUI

struct ProximityIndicatorView: View {
    let distance: Double
    
    private var isSignalWeek: Bool {
        distance > 1.5
    }
    
    private var outerCircleSize: CGFloat {
        let clamped = min(max(distance, 0), TrackerDisplayConstants.circleMaxSize)
        return TrackerDisplayConstants.circleMinSize + (clamped * TrackerDisplayConstants.circleGrowthFactor)
    }
    
    var body: some View {
        ZStack {
            if isSignalWeek {
                VStack {
                    Text("Connected")
                        .bold()
                    Text("Signal is weak. Try moving to a different location")
                        .bold()
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: TrackerDisplayConstants.circleBaseSize)
            } else {
                Circle()
                    .fill(.white)
                    .frame(
                        width: TrackerDisplayConstants.circleBaseSize,
                        height: TrackerDisplayConstants.circleBaseSize
                    )
                    .overlay {
                        Circle()
                            .fill(.white)
                            .opacity(0.3)
                            .frame(width: outerCircleSize, height: outerCircleSize)
                            .animation(.easeInOut, value: distance)
                    }
            }
        }
        .animation(.default, value: isSignalWeek)
    }
}

#Preview {
    @Previewable @State var distance: Double = 0
    VStack {
        Spacer()
        ProximityIndicatorView(distance: distance)
        Spacer()
        Slider(
            value: $distance,
            in: 0...TrackerDisplayConstants.weakSignalThreshold + 0.5
        )
        .accentColor(.orange)
        .padding()
    }
    .background(.blue)
}
