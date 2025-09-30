//
//  DistanceDisplayView.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 29/09/25.
//

import SwiftUI
import CoreLocation

struct DistanceDisplayView: View {
    let distance: Double
    let proximity: CLProximity
    
    private var formattedDistance: FormattedDistance {
        DistanceFormatter.format(meters: distance)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text(formattedDistance.value)
                        .font(.system(size: 60, design: .rounded))
                    
                    Text(formattedDistance.unit)
                        .font(.system(size: 50, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Text(proximity.description)
                    .font(.system(size: 50, design: .rounded))
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    DistanceDisplayView(distance: 0.2, proximity: .near)
}
