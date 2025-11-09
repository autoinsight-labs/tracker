//
//  EmptyResponse.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import Foundation

struct EmptyResponse: Decodable {
    init() {}
    
    init(from decoder: Decoder) throws {
        // Accept empty JSON objects without throwing.
    }
}

