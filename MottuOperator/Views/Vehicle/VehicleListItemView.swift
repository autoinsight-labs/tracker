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
    
    private var beaconKey: String? {
        guard let beacon = vehicle.beacon else { return nil }
        return "\(beacon.uuid)_\(beacon.major)_\(beacon.minor)"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(vehicle.plate)
                    .font(.headline)
                
                vehicleMetadata
            }
            
            Spacer()
            
            distanceView
        }
        .task(id: vehicle.beacon?.id) {
            guard let beacon = vehicle.beacon else {
                distance = .notAvailable
                return
            }
            guard
                let major = beacon.majorAsUInt16,
                let minor = beacon.minorAsUInt16
            else {
                distance = .notAvailable
                return
            }
            
            distance = .loading
            beaconService.startRanging(
                uuid: beacon.uuid,
                major: major,
                minor: minor
            )
            
            let timeout = Date().addingTimeInterval(10)
            
            while Date() < timeout {
                if let key = beaconKey,
                   let rawDistance = beaconService.distances[key] {
                    distance = .found(formatDistance(rawDistance))
                    return
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
            
            distance = .notFound
        }
 
    }
    
    @ViewBuilder
    private var vehicleMetadata: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(vehicle.model.displayName)
                Text("•")
                Text(vehicle.status.displayName)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            
            Text(vehicle.enteredAt.formatted(date: .abbreviated, time: .shortened))
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
    }
    
    @ViewBuilder
    private var distanceView: some View {
        switch distance {
        case .loading:
            if vehicle.beacon != nil {
                ProgressView()
                    .controlSize(.regular)
            } else {
                Text("—")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        case .found(let value):
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .notFound:
            Text("No signal")
                .font(.footnote)
                .foregroundStyle(.secondary)
        case .notAvailable:
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .foregroundStyle(.secondary)
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
        case notAvailable
        case loading
        case found(String)
        case notFound
    }
}

/*
 #Preview {
     VehicleListItemView(vehicle: vehicle)
         .environment(BeaconService())
         .padding(.horizontal)
 }
 **/

