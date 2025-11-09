//
//  VehicleDetail.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import Foundation

struct VehicleDetail: Identifiable, Codable {
    struct Assignee: Codable {
        let id: UUID
        let name: String
        let imageUrl: URL?
        let role: String
        let userId: String
    }
    
    struct Beacon: Codable {
        let id: UUID
        let uuid: UUID
        let major: String
        let minor: String
    }
    
    let id: UUID
    let plate: String
    let model: Vehicle.Model
    let status: Vehicle.Status
    let enteredAt: Date
    let leftAt: Date?
    let assignee: Assignee?
    let beacon: Beacon?
}

extension VehicleDetail.Beacon {
    var majorAsUInt16: UInt16? {
        UInt16(major)
    }
    
    var minorAsUInt16: UInt16? {
        UInt16(minor)
    }
}

