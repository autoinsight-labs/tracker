//
//  BeaconService.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 27/09/25.
//

import Foundation
import CoreLocation

extension CLProximity {
    var description: String {
        switch self {
        case .unknown: return "unknown"
        case .far: return "far"
        case .near: return "near"
        case .immediate: return "immediate"
        @unknown default:
            return "unknown"
        }
    }
}

@Observable
class BeaconService: NSObject, CLLocationManagerDelegate {
    var distances: [String: Double] = [:]
    var proximities: [String: CLProximity] = [:]
    
    private let smoothingFactor: Double = 0.15
    private let minAccuracy: Double = 0.01

    private func updateDistance(for key: String, newAccuracy: Double) {
        guard newAccuracy > minAccuracy else { return }
        
        let old = distances[key] ?? newAccuracy
        let smoothed = old + (newAccuracy - old) * smoothingFactor
        
        distances[key] = smoothed
    }
    
    private let locationManager = CLLocationManager()
    private let defaultUUID: UUID
    
    init(defaultUUID: UUID? = nil) {
        self.defaultUUID = defaultUUID ?? UUID()
        super.init()
        locationManager.delegate = self
    }
    
    func startRanging(uuid: UUID? = nil, major: CLBeaconMajorValue? = nil, minor: CLBeaconMinorValue? = nil) {
        checkAuthorization { [weak self] authorized in
            guard let self = self else { return }
            if authorized {
                let uuidToUse = uuid ?? self.defaultUUID
                
                let constraint: CLBeaconIdentityConstraint
                if let major = major, let minor = minor {
                    constraint = CLBeaconIdentityConstraint(uuid: uuidToUse, major: major, minor: minor)
                } else if let major = major {
                    constraint = CLBeaconIdentityConstraint(uuid: uuidToUse, major: major)
                } else {
                    constraint = CLBeaconIdentityConstraint(uuid: uuidToUse)
                }
                
                self.locationManager.startRangingBeacons(satisfying: constraint)
            } else {
                print("Permission for location not provided")
            }
        }
    }
    
    private func checkAuthorization(completion: @escaping (Bool) -> Void) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            self.pendingAuthorizationCallback = completion
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        case .restricted, .denied:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private var pendingAuthorizationCallback: ((Bool) -> Void)?
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if let callback = pendingAuthorizationCallback {
            let authorized = manager.authorizationStatus == .authorizedWhenInUse ||
                             manager.authorizationStatus == .authorizedAlways
            callback(authorized)
            pendingAuthorizationCallback = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying constraint: CLBeaconIdentityConstraint) {
        for beacon in beacons {
            let key = "\(beacon.uuid.uuidString)_\(beacon.major)_\(beacon.minor)"
            if beacon.accuracy > 0 {
                updateDistance(for: key, newAccuracy: beacon.accuracy)
                proximities[key] = beacon.proximity
            }
        }
    }
}
