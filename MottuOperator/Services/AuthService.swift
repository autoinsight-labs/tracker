//
//  AuthService.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 03/11/25.
//

import Foundation
import Firebase
import FirebaseAuth
import UIKit

enum AuthenticationError: Error {
    case runtimeError(String)
    case notNewUser
}

@Observable
class AuthService {
    var user: User? = nil
    var isSignedIn: Bool = false
    
    init() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = user != nil
    }
    
    func signUp(fullName: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {  result, error in
            if let error = error {
                print("Sign Up Error:")
                print(error)
                completion(error)
                return
            }
            
            guard let user = result?.user else {
                completion(AuthenticationError.runtimeError("User not found after creation"))
                return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Error while defining user name:", error)
                }
                
                self.user = Auth.auth().currentUser
                self.isSignedIn = self.user != nil
                completion(error)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign In Error: \(error.localizedDescription)")
                self.user = nil
                self.isSignedIn = false
                completion(error)
                return
            }
            
            self.user = Auth.auth().currentUser
            self.isSignedIn = self.user != nil
            completion(nil)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isSignedIn = false
        } catch {
            print("Sign Out Error: \(error.localizedDescription)")
        }
    }
    
    func getIDToken(forceRefresh: Bool = false) async throws -> String {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthenticationError.runtimeError("User not signed in")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            currentUser.getIDTokenForcingRefresh(forceRefresh) { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let token = token else {
                    continuation.resume(throwing: AuthenticationError.runtimeError("Failed to retrieve ID token"))
                    return
                }
                
                continuation.resume(returning: token)
            }
        }
    }
}
