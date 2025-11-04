//
//  NetworkError.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 03/11/25.
//

enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case failedToDecodeResponse
}
