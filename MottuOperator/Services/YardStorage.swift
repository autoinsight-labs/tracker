//
//  YardStorage.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import Foundation

protocol YardIDStoring {
    func save(yardID: UUID)
    func loadYardID() -> UUID?
    func clearYardID()
}

struct UserDefaultsYardIDStorage: YardIDStoring {
    private let key = "com.autoinsight.tracker.yardId"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save(yardID: UUID) {
        userDefaults.set(yardID.uuidString, forKey: key)
    }
    
    func loadYardID() -> UUID? {
        guard let storedString = userDefaults.string(forKey: key) else {
            return nil
        }
        return UUID(uuidString: storedString)
    }
    
    func clearYardID() {
        userDefaults.removeObject(forKey: key)
    }
}

