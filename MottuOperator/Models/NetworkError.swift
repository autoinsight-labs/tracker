//
//  NetworkError.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 03/11/25.
//

import Foundation

enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus(code: Int, data: Data?)
    case failedToDecodeResponse
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badUrl:
            return String(localized: "The URL is invalid.")
        case .invalidRequest:
            return String(localized: "The request could not be built.")
        case .badResponse:
            return String(localized: "The server returned an unexpected response.")
        case let .badStatus(code, data):
            if let message = NetworkError.extractErrorMessage(from: data) {
                return "\(message) (code \(code))"
            }
            return "The request failed with status code \(code)."
        case .failedToDecodeResponse:
            return String(localized: "We couldn't decode the server response.")
        }
    }
    
    private static func extractErrorMessage(from data: Data?) -> String? {
        guard let data else { return nil }
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: data) {
            if let dictionary = jsonObject as? [String: Any] {
                if let message = dictionary["message"] as? String {
                    return message
                }
                if let detail = dictionary["detail"] as? String {
                    return detail
                }
                if let errors = dictionary["errors"] as? [String: Any] {
                    let joined = errors
                        .flatMap { $0.value as? [String] ?? [] }
                        .joined(separator: "\n")
                    if !joined.isEmpty {
                        return joined
                    }
                }
            } else if let array = jsonObject as? [String], let first = array.first {
                return first
            }
        }
        
        if let message = String(data: data, encoding: .utf8),
           !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return message
        }
        
        return nil
    }
}
