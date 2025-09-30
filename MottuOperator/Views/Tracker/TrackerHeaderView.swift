//
//  TrackerHeaderView.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 29/09/25.
//

import SwiftUI

struct TrackerHeaderView: View {
    let vehicleId: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Finding".uppercased())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(vehicleId)
                    .font(.largeTitle)
                    .bold()
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    TrackerHeaderView(vehicleId: "BRA0S17")
}
