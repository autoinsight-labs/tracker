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
    @Environment(InviteService.self) private var inviteService: InviteService
    @Environment(VehicleService.self) private var vehicleService: VehicleService
    
    var body: some View {
        NavigationStack {
            if authService.isSignedIn {
                if inviteService.activeYardID != nil {
                    VehicleListView()
                } else {
                    PendingInvitesView()
                }
            } else {
                SignUpView()
            }
        }
        .onChange(of: inviteService.activeYardID) { _, newValue in
            if newValue == nil {
                Task { vehicleService.clear() }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(BeaconService(defaultUUID: UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB11111111")!))
        .environment(AuthService())
}
