//
//  VehicleListView.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 29/09/25.
//

import SwiftUI

struct VehicleListView: View {
    @Environment(InviteService.self) private var inviteService: InviteService
    @Environment(VehicleService.self) private var vehicleService: VehicleService
    
    @State private var search = ""
    @State private var isPresentingCreate = false
    
    var filteredVehicles: [Vehicle] {
        if search.isEmpty {
            return vehicleService.vehicles
        }
        
        return vehicleService.vehicles.filter {
            $0.plate.localizedCaseInsensitiveContains(search)
        }
    }
    
    var body: some View {
        Group {
            if let yardId = inviteService.activeYardID {
                content(for: yardId)
            } else {
                emptyYardPlaceholder
            }
        }
        .navigationTitle("Yard Vehicles")
        .searchable(text: $search)
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                if inviteService.activeYardID != nil {
                    Button {
                        isPresentingCreate = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .task(id: inviteService.activeYardID) { [inviteService] in
            guard let yardId = inviteService.activeYardID else {
                vehicleService.clear()
                return
            }
            await vehicleService.fetchVehicles(for: yardId, forceRefresh: vehicleService.currentYardID != yardId)
        }
        .sheet(isPresented: $isPresentingCreate) {
            if let yardId = inviteService.activeYardID {
                VehicleCreateView(yardID: yardId)
                    .environment(vehicleService)
            }
        }
    }
}

private extension VehicleListView {
    @ViewBuilder
    func content(for yardId: UUID) -> some View {
        if vehicleService.isLoading && vehicleService.vehicles.isEmpty {
            loadingView
        } else if let error = vehicleService.errorMessage, vehicleService.vehicles.isEmpty {
            errorView(for: yardId, message: error)
        } else if filteredVehicles.isEmpty {
            emptyState
        } else {
            vehiclesList(for: yardId)
        }
    }
    
    var emptyYardPlaceholder: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Select a yard to view the vehicles.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading vehicles...")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func errorView(for yardId: UUID, message: String) -> some View {
        VStack(spacing: 16) {
            Text("We couldn't load the vehicles.")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again") {
                Task {
                    await vehicleService.fetchVehicles(for: yardId, forceRefresh: true)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var emptyState: some View {
        VStack(spacing: 16) {
            if search.isEmpty {
                Text("No vehicles available.")
                    .font(.headline)
                Text("New vehicles added to this yard will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("No vehicles found for \"\(search)\".")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text("Adjust your search text or clear the filter.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func vehiclesList(for yardId: UUID) -> some View {
        List(filteredVehicles) { vehicle in
            NavigationLink {
                VehicleDetailView(
                    yardID: yardId,
                    vehicleID: vehicle.id
                )
            } label: {
                VehicleListItemView(vehicle: vehicle)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await vehicleService.fetchVehicles(for: yardId, forceRefresh: true)
        }
    }
}
