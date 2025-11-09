//
//  Vehicle.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 29/09/25.
//

import Foundation

struct Vehicle: Identifiable, Codable {
    let id: UUID
    let plate: String
    let model: Model
    let status: Status
    let enteredAt: Date
    let leftAt: Date?
    let beacon: Beacon

    struct Beacon: Identifiable, Codable {
        let id: UUID
        let uuid: UUID
        let major: UInt16
        let minor: UInt16
    }
    
    enum Model: String, CaseIterable, Codable {
        case MottuSport110i = "Mottu Sport"
        case Mottue = "Mottu E"
        case HondaPop110i = "Honda Pop"
        case TVSSport110i = "TVS Sport"
    }
    
    enum Status: String, CaseIterable, Codable {
        case Scheduled
        case Waiting
        case OnService
        case Finished
        case Cancelled
    }
}
