//
//  TrackerView.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 29/09/25.
//

import SwiftUI
import CoreLocation

struct TrackerView: View {
    @Environment(BeaconService.self) private var beaconService: BeaconService
    
    let uuid: UUID
    let major: UInt16
    let minor: UInt16
    let vehicleId: String
    
    private var beaconData: BeaconData {
        let beaconKey = "\(uuid.uuidString)_\(major)_\(minor)"
        
        return BeaconData(
            distance: beaconService.distances[beaconKey] ?? 0.0,
            proximity: beaconService.proximities[beaconKey] ?? .unknown
        )
    }

    var body: some View {
        VStack {
            TrackerHeaderView(vehicleId: vehicleId)
            Spacer()
            ProximityIndicatorView(distance: beaconData.distance)
            Spacer()
            DistanceDisplayView(
                distance: beaconData.distance,
                proximity: beaconData.proximity
            )
        }
        .onAppear {
            beaconService.startRanging(uuid: uuid, major: major, minor: minor)
        }
        .background(.blue)
        .foregroundStyle(.white)
    }
    
    private struct BeaconData {
        let distance: Double
        let proximity: CLProximity
    }
}

#Preview {
    TrackerView(
        uuid: UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825") ?? UUID(),
        major: 10167,
        minor: 61958,
        vehicleId: "BRA0S17"
    )
    .environment(BeaconService())
}
