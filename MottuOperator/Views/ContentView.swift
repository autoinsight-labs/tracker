//
//  ContentView.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 27/09/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @Environment(AuthService.self) private var authService: AuthService
    
    let mockVehicles: [Vehicle] = [
        
        Vehicle(
            id: UUID(),
            identifier: "BRA0S17",
            beacon: Vehicle.BeaconData(
                id: UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825") ?? UUID(),
                major: 10167,
                minor: 61958
            ),
            model: Vehicle.Model(
                name: "Mottu Model E",
                year: 2020
            )
        ),
        Vehicle(
            id: UUID(),
            identifier: "BRA0S18",
            beacon: Vehicle.BeaconData(
                id: UUID(),
                major: 10001,
                minor: 50001
            ),
            model: Vehicle.Model(
                name: "Mottu Model E",
                year: 2021
            )
        ),
        Vehicle(
            id: UUID(),
            identifier: "BRA0S19",
            beacon: Vehicle.BeaconData(
                id: UUID(),
                major: 10002,
                minor: 50002
            ),
            model: Vehicle.Model(
                name: "Mottu Model S",
                year: 2022
            )
        ),
        Vehicle(
            id: UUID(),
            identifier: "BRA0S20",
            beacon: Vehicle.BeaconData(
                id: UUID(),
                major: 10003,
                minor: 50003
            ),
            model: Vehicle.Model(
                name: "Mottu Model S",
                year: 2023
            )
        ),
        Vehicle(
            id: UUID(),
            identifier: "SPX1234",
            beacon: Vehicle.BeaconData(
                id: UUID(),
                major: 12000,
                minor: 62000
            ),
            model: Vehicle.Model(
                name: "Mottu Cargo",
                year: 2019
            )
        ),
        Vehicle(
            id: UUID(),
            identifier: "SPX5678",
            beacon: Vehicle.BeaconData(
                id: UUID(),
                major: 12001,
                minor: 62001
            ),
            model: Vehicle.Model(
                name: "Mottu Cargo",
                year: 2020
            )
        ),
        Vehicle(
            id: UUID(),
            identifier: "RIO4321",
            beacon: Vehicle.BeaconData(
                id: UUID(),
                major: 13000,
                minor: 63000
            ),
            model: Vehicle.Model(
                name: "Mottu City",
                year: 2018
            )
        ),
        Vehicle(
            id: UUID(),
            identifier: "FOR9876",
            beacon: Vehicle.BeaconData(
                id: UUID(),
                major: 14000,
                minor: 64000
            ),
            model: Vehicle.Model(
                name: "Mottu City",
                year: 2022
            )
        )
    ]
    
    var body: some View {
        NavigationStack {
            if authService.isSignedIn {
                VehicleListView(
                    vehicles: mockVehicles
                )
            } else {
                SignUpView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(BeaconService(defaultUUID: UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB11111111")!))
        .environment(AuthService())
}
