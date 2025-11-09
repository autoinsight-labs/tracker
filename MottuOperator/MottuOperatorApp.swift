//
//  MottuOperatorApp.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 27/09/25.
//

import SwiftUI
import Firebase

@main
struct MottuOperatorApp: App {
    @State private var authService: AuthService
    @State private var inviteService: InviteService
    @State private var vehicleService: VehicleService
    
    init() {
        FirebaseApp.configure()
    
        let auth = AuthService()
        let inviteService = InviteService(authService: auth)
        let vehicleService = VehicleService()
        _authService = State(initialValue: auth)
        _inviteService = State(initialValue: inviteService)
        _vehicleService = State(initialValue: vehicleService)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(BeaconService())
                .environment(authService)
                .environment(inviteService)
                .environment(vehicleService)
        }
    }
}
