//
//  YardEmployee.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import Foundation

struct YardEmployee: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageUrl: URL?
    let role: String
    let userId: String
}

