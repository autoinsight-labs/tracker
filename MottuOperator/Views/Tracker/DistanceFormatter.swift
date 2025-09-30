//
//  DistanceFormatter.swift
//  MottuOperator
//
//  Created by Arthur Mariano on 29/09/25.
//

import Foundation


struct FormattedDistance {
    let value: String
    let unit: String
}

enum DistanceFormatter {
    static func format(meters: Double) -> FormattedDistance {
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 1
        formatter.numberFormatter.minimumFractionDigits = 1
        formatter.unitOptions = .naturalScale
        
        let formattedString = formatter.string(from: measurement)
        
        guard let splitIndex = formattedString.firstIndex(where: {
            !"0123456789.,".contains($0)
        }) else {
            return FormattedDistance(value: formattedString, unit: "m")
        }
        
        let value = String(formattedString[..<splitIndex])
        let unit = String(formattedString[splitIndex...])
        
        return FormattedDistance(value: value, unit: unit)
    }
}
