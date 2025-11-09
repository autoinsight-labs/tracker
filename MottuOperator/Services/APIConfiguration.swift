//
//  APIConfiguration.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import Foundation

enum APIConfiguration {
    private static let defaultBaseURL = "http://localhost:5232"
    private static let infoPlistKey = "API_BASE_URL"
    
    static var baseURL: String {
        #if DEBUG
        if let urlFromEnvironment = ProcessInfo.processInfo.environment[infoPlistKey], !urlFromEnvironment.isEmpty {
            return urlFromEnvironment
        }
        #endif
        
        if let urlFromInfoPlist = Bundle.main.object(forInfoDictionaryKey: infoPlistKey) as? String, !urlFromInfoPlist.isEmpty {
            return urlFromInfoPlist
        }
        
        return defaultBaseURL
    }
}

