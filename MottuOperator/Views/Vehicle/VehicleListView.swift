//
//  VehicleListView.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 29/09/25.
//

import SwiftUI

struct VehicleListView: View {
    @State private var search = ""
    var vehicles = [Vehicle]()
    
    var filteredVehicles: [Vehicle] {
        if search.isEmpty {
            return vehicles
        }
        
        return vehicles.filter {
            $0.plate.localizedCaseInsensitiveContains(search)
        }
    }
    
    var body: some View {
        List(filteredVehicles) { vehicle in
            NavigationLink {
                TrackerView(
                    uuid: vehicle.beacon.id,
                    major: vehicle.beacon.major,
                    minor: vehicle.beacon.minor,
                    vehicleId: vehicle.plate
                )
            } label: {
                VehicleListItemView(vehicle: vehicle)
            }
        }
        .searchable(text: $search)
        .navigationTitle("Yard Vehicles")
    }
}

#Preview {
    let mockVehicles = [Vehicle]()
    
    NavigationStack {
        VehicleListView(vehicles: mockVehicles)
            .environment(BeaconService())
    }
}
