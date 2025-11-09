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
    let assigneeId: UUID?
    let beacon: Beacon?

    struct Beacon: Identifiable, Codable {
        let id: UUID
        let uuid: UUID
        let major: String
        let minor: String
        
        var majorAsUInt16: UInt16? { UInt16(major) }
        var minorAsUInt16: UInt16? { UInt16(minor) }
    }
    
    enum Model: String, CaseIterable, Codable {
        case mottuSport110i = "MottuSport110i"
        case mottue = "Mottue"
        case hondaPop110i = "HondaPop110i"
        case tvsSport110i = "TVSSport110i"
        
        var displayName: String {
            switch self {
            case .mottuSport110i:
                return "Mottu Sport"
            case .mottue:
                return "Mottu E"
            case .hondaPop110i:
                return "Honda Pop"
            case .tvsSport110i:
                return "TVS Sport"
            }
        }
    }
    
    enum Status: String, CaseIterable, Codable {
        case scheduled = "Scheduled"
        case waiting = "Waiting"
        case onService = "OnService"
        case finished = "Finished"
        case cancelled = "Cancelled"
        
        var displayName: String {
            switch self {
            case .scheduled:
                return String(localized: "Scheduled", comment: "Vehicle status scheduled")
            case .waiting:
                return String(localized: "Waiting", comment: "Vehicle status waiting")
            case .onService:
                return String(localized: "On service", comment: "Vehicle status on service")
            case .finished:
                return String(localized: "Finished", comment: "Vehicle status finished")
            case .cancelled:
                return String(localized: "Cancelled", comment: "Vehicle status cancelled")
            }
        }
    }
}
