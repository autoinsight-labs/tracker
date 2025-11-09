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
    
    let mockVehicles: [Vehicle] = []
    
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
