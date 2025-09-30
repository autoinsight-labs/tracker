//
//  MottuOperatorApp.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 27/09/25.
//

import SwiftUI

@main
struct MottuOperatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(BeaconService())
        }
    }
}
