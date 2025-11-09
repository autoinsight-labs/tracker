//
//  Invite.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import Foundation

struct PaginatedResponse<T: Decodable>: Decodable {
    let data: [T]
    let pageInfo: PageInfo
    let count: Int
}

struct PageInfo: Decodable {
    let nextCursor: String?
    let hasNextPage: Bool
}

struct Invite: Identifiable, Codable {
    let id: UUID
    let email: String
    let role: String
    let status: InviteStatus
    let createdAt: Date
    let acceptedAt: Date?
    let inviterId: String
    let yard: YardSummary
}

struct YardSummary: Codable {
    let id: UUID
    let name: String
}

enum InviteStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case rejected = "Rejected"
}

