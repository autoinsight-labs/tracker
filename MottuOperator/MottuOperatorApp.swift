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
    
    init() {
        FirebaseApp.configure()
    
        let auth = AuthService()
        _authService = State(initialValue: auth)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(BeaconService())
                .environment(authService)
        }
    }
}
