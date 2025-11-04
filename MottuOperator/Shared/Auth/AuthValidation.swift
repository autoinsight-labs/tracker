//
//  AuthValidation.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 03/11/25.
//

import SwiftUI
import Foundation

enum AuthValidation {
    
    static func borderColor(for error: String?) -> Color {
        error != nil ? .red : Color(.separator)
    }
    
    static func validateFullName(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Name is required."
        } else if trimmed.count < 3 {
            return "Enter your full name."
        } else {
            return nil
        }
    }
    
    static func validateEmail(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Email is required."
        } else if !trimmed.contains("@") {
            return "Use a valid email."
        } else {
            return nil
        }
    }
    
    static func validatePassword(_ password: String) -> String? {
        if password.isEmpty {
            return "Password is required."
        } else if password.count < 6 {
            return "Password must have at least 6 characters."
        } else {
            return nil
        }
    }
    
    static func validateConfirmPassword(_ password: String, _ confirmPassword: String) -> String? {
        if confirmPassword.isEmpty {
            return "Please confirm your password."
        } else if confirmPassword != password {
            return "Passwords do not match."
        } else {
            return nil
        }
    }
    
    static func isFormValid(fullName: String? = nil, email: String, password: String, confirmPassword: String? = nil) -> Bool {
        guard validateEmail(email) == nil, validatePassword(password) == nil else {
            return false
        }
        
        if let fullName {
            return validateFullName(fullName) == nil
        }
        
        if let confirmPassword {
            return validateConfirmPassword(password, confirmPassword) == nil
        }
        
        return true
    }
    
    static func mapAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return "Connection failed. Please try again later."
        }
        return "Incorrect credentials."
    }
}
