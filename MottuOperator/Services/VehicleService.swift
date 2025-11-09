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
}

