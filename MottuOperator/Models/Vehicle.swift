//
//  Vehicle.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 29/09/25.
//

import Foundation

struct Vehicle: Identifiable, Codable {
    let id: UUID
    let identifier: String
    let beacon: BeaconData
    let model: Model
    
    struct Model: Codable {
        let name: String
        let year: Int
    }
    
    struct BeaconData: Identifiable, Codable {
        let id: UUID
        let major: UInt16
        let minor: UInt16
    }
}
