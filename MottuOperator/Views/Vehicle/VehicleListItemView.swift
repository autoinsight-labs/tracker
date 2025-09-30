//
//  VehicleListItemView.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 29/09/25.
//

import SwiftUI

struct VehicleListItemView: View {
    @Environment(BeaconService.self) private var beaconService: BeaconService
    @State private var distance: DistanceState = .loading
    
    let vehicle: Vehicle
    
    var beaconKey: String {
        "\(vehicle.beacon.id)_\(vehicle.beacon.major)_\(vehicle.beacon.minor)"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(vehicle.identifier)
                    .font(.headline)
                
                HStack {
                    Text(vehicle.model.name)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    
                    Text(vehicle.model.year, format: .number.grouping(.never))
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
            
            Spacer()
            
            switch distance {
            case .loading:
                ProgressView()
                    .controlSize(.regular)
            case .found(let distance):
                Text(distance)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            case .notFound:
                Text("—")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
        .task {
            beaconService.startRanging(
                uuid: vehicle.beacon.id,
                major: vehicle.beacon.major,
                minor: vehicle.beacon.minor
            )
            
            let timeout = Date().addingTimeInterval(10)
            
            while Date() < timeout {
                if let rawDistance = beaconService.distances[beaconKey] {
                    distance = .found(formatDistance(rawDistance))
                    return
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
            
            distance = .notFound
        }
 
    }
    
    private func formatDistance(_ rawDistance: Double) -> String {
        let measurement = Measurement(value: rawDistance, unit: UnitLength.meters)
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 1
        formatter.numberFormatter.minimumFractionDigits = 1
        formatter.unitOptions = .naturalScale
        
        return formatter.string(from: measurement)
    }
    
    private enum DistanceState {
        case loading
        case found(String)
        case notFound
    }
}

#Preview {
    let vehicle = Vehicle(
        id: UUID(),
        identifier: "BRA0S17",
        beacon: Vehicle.BeaconData(
            id: UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825") ?? UUID(),
            major: 10167,
            minor: 61958,
        ),
        model: Vehicle.Model(
            name: "Mottu Model E",
            year: 2020
        )
    )
    
    VehicleListItemView(vehicle: vehicle)
        .environment(BeaconService())
        .padding(.horizontal)
}

