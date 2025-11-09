//
//  VehicleService.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import Foundation
import Observation

@Observable
class VehicleService {
    private let webService: WebServicing
    private let decoderConfigurator: (JSONDecoder) -> Void = { decoder in
        decoder.dateDecodingStrategy = .iso8601
    }
    
    private(set) var vehicles: [Vehicle] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    private(set) var currentYardID: UUID?
    
    init(webService: WebServicing = WebService()) {
        self.webService = webService
    }
    
    @MainActor
    func clear() {
        vehicles = []
        errorMessage = nil
        currentYardID = nil
        isLoading = false
    }
    
    func fetchVehicles(for yardID: UUID, forceRefresh: Bool = false) async {
        if !forceRefresh, currentYardID == yardID, !vehicles.isEmpty {
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
            if self.currentYardID != yardID {
                self.vehicles = []
            }
            self.currentYardID = yardID
        }
        
        let endpoint = "\(APIConfiguration.baseURL)/v2/yards/\(yardID.uuidString)/vehicles"
        
        do {
            let response: PaginatedResponse<Vehicle> = try await webService.sendRequest(
                toURL: endpoint,
                method: .get,
                headers: nil,
                body: nil,
                configureDecoder: decoderConfigurator
            )
            
            await MainActor.run {
                self.vehicles = response.data
                self.isLoading = false
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func fetchVehicleDetail(for yardID: UUID, vehicleID: UUID) async throws -> VehicleDetail {
        let endpoint = "\(APIConfiguration.baseURL)/v2/yards/\(yardID.uuidString)/vehicles/\(vehicleID.uuidString)"
        return try await webService.sendRequest(
            toURL: endpoint,
            method: .get,
            headers: nil,
            body: nil,
            configureDecoder: decoderConfigurator
        )
    }
    
    func updateVehicle(
        yardID: UUID,
        vehicleID: UUID,
        update: VehicleUpdateRequest
    ) async throws -> VehicleDetail {
        let endpoint = "\(APIConfiguration.baseURL)/v2/yards/\(yardID.uuidString)/vehicles/\(vehicleID.uuidString)"
        let body = try JSONEncoder().encode(update)
        
        return try await webService.sendRequest(
            toURL: endpoint,
            method: .patch,
            headers: ["Content-Type": "application/json"],
            body: body,
            configureDecoder: decoderConfigurator
        )
    }
    
    func fetchEmployees(for yardID: UUID) async throws -> [YardEmployee] {
        let endpoint = "\(APIConfiguration.baseURL)/v2/yards/\(yardID.uuidString)/employees"
        let response: PaginatedResponse<YardEmployee> = try await webService.sendRequest(
            toURL: endpoint,
            method: .get,
            headers: nil,
            body: nil,
            configureDecoder: decoderConfigurator
        )
        return response.data
    }
    
    func createVehicle(
        in yardID: UUID,
        request: VehicleCreateRequest
    ) async throws -> VehicleDetail {
        let endpoint = "\(APIConfiguration.baseURL)/v2/yards/\(yardID.uuidString)/vehicles"
        let body = try JSONEncoder().encode(request)
        
        return try await webService.sendRequest(
            toURL: endpoint,
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: body,
            configureDecoder: decoderConfigurator
        )
    }
}

struct VehicleUpdateRequest: Encodable {
    struct Beacon: Encodable {
        let uuid: UUID
        let major: String
        let minor: String
    }
    
    let status: Vehicle.Status?
    let assigneeId: UUID?
    let beacon: Beacon?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let status {
            try container.encode(status.rawValue, forKey: .status)
        }
        if let assigneeId {
            try container.encode(assigneeId, forKey: .assigneeId)
        }
        if let beacon {
            try container.encode(beacon, forKey: .beacon)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case status
        case assigneeId
        case beacon
    }
}

struct VehicleCreateRequest: Encodable {
    struct Beacon: Encodable {
        let uuid: UUID
        let major: Int
        let minor: Int
    }
    
    let plate: String
    let model: Vehicle.Model
    let beacon: Beacon
    let assigneeId: UUID?
    
    private enum CodingKeys: String, CodingKey {
        case plate
        case model
        case beacon
        case assigneeId
    }
}

