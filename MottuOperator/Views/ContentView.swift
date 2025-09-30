//
//  ContentView.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 27/09/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    var body: some View {
        TrackerView(
            uuid: UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825") ?? UUID(),
            major: 10167,
            minor: 61958,
            vehicleId: "BRA0S17"
        )
    }
}

#Preview {
    ContentView()
        .environment(BeaconService(defaultUUID: UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB11111111")!))
}
