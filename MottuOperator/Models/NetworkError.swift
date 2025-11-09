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
            return NSLocalizedString("The URL is invalid.", comment: "Error description shown when building the request URL fails.")
        case .invalidRequest:
            return NSLocalizedString("The request could not be built.", comment: "Error description when the HTTP request could not be composed.")
        case .badResponse:
            return NSLocalizedString("The server returned an unexpected response.", comment: "Error description when the server response is invalid.")
        case let .badStatus(code, data):
            if let message = NetworkError.extractErrorMessage(from: data) {
                let format = NSLocalizedString(
                    "%@ (code %lld)",
                    comment: "API error with message and status code"
                )
                return String(format: format, message, Int64(code))
            }
            let format = NSLocalizedString(
                "The request failed with status code %lld.",
                comment: "Generic error message when an HTTP request fails with a status code."
            )
            return String(format: format, Int64(code))
        case .failedToDecodeResponse:
            return NSLocalizedString("We couldn't decode the server response.", comment: "Error description when decoding a server response fails.")
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
