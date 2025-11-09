//
//  WebService.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 08/11/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol WebServicing {
    func sendRequest<T: Decodable>(
        toURL: String,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        configureDecoder: ((JSONDecoder) -> Void)?
    ) async throws -> T
}

extension WebServicing {
    func downloadData<T: Decodable>(
        fromURL: String,
        headers: [String: String]? = nil,
        configureDecoder: ((JSONDecoder) -> Void)? = nil
    ) async throws -> T {
        try await sendRequest(
            toURL: fromURL,
            method: .get,
            headers: headers,
            body: nil,
            configureDecoder: configureDecoder
        )
    }
}

class WebService: WebServicing {
    func sendRequest<T: Decodable>(
        toURL: String,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: Data? = nil,
        configureDecoder: ((JSONDecoder) -> Void)? = nil
    ) async throws -> T {
        guard let url = URL(string: toURL) else {
            throw NetworkError.badUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.httpBody = body
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw NetworkError.badResponse }
        guard (200..<300).contains(response.statusCode) else {
            throw NetworkError.badStatus(code: response.statusCode, data: data)
        }
        
        if data.isEmpty, T.self == EmptyResponse.self {
            guard let emptyResponse = EmptyResponse() as? T else {
                throw NetworkError.failedToDecodeResponse
            }
            return emptyResponse
        }
        
        let decoder = JSONDecoder()
        configureDecoder?(decoder)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.failedToDecodeResponse
        }
    }
}