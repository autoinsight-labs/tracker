//
//  InviteService.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import Foundation
import Observation
import FirebaseAuth

@Observable
class InviteService {
    private let webService: WebServicing
    private let authService: AuthService
    private let yardStorage: YardIDStoring
    
    private let decoderConfigurator: (JSONDecoder) -> Void = { decoder in
        decoder.dateDecodingStrategy = .iso8601
    }
    
    private(set) var pendingInvites: [Invite] = []
    private(set) var activeYardID: UUID?
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    init(
        webService: WebServicing = WebService(),
        authService: AuthService,
        yardStorage: YardIDStoring = UserDefaultsYardIDStorage()
    ) {
        self.webService = webService
        self.authService = authService
        self.yardStorage = yardStorage
        self.activeYardID = yardStorage.loadYardID()
    }
    
    func fetchData() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let token = try await authService.getIDToken()
            let response: PaginatedResponse<Invite> = try await webService.sendRequest(
                toURL: "\(APIConfiguration.baseURL)/v2/invites/user",
                method: .get,
                headers: [
                    "Authorization": "Bearer \(token)"
                ],
                body: nil,
                configureDecoder: decoderConfigurator
            )
            
            let filteredInvites = response.data.filter { $0.status == .pending }
            
            await MainActor.run {
                self.pendingInvites = filteredInvites
                self.isLoading = false
                self.errorMessage = nil
            }
        } catch let NetworkError.badStatus(code, data) {
            await MainActor.run {
                let fallbackFormat = NSLocalizedString(
                    "We couldn't load your invites. (code %lld)",
                    comment: "Fallback error message with status code when invite loading fails."
                )
                let fallback = String(format: fallbackFormat, Int64(code))
                let message = InviteService.extractErrorMessage(from: data) ?? fallback
                self.errorMessage = message
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func accept(invite: Invite, name: String? = nil, imageURL: URL? = nil, forceRefreshToken: Bool = false) async throws {
        let resolvedName = resolveName(for: invite, overridingWith: name)
        let payload = AcceptInviteRequest(
            name: resolvedName,
            imageUrl: imageURL?.absoluteString
        )
        
        let token = try await authService.getIDToken(forceRefresh: forceRefreshToken)
        let body = try JSONEncoder().encode(payload)
        
        do {
            _ = try await webService.sendRequest(
                toURL: "\(APIConfiguration.baseURL)/v2/invites/\(invite.id.uuidString)/accept",
                method: .post,
                headers: [
                    "Authorization": "Bearer \(token)",
                    "Accept": "application/json"
                ],
                body: body,
                configureDecoder: decoderConfigurator
            ) as EmptyResponse
        } catch let NetworkError.badStatus(code, _) where code == 401 && !forceRefreshToken {
            try await accept(invite: invite, name: resolvedName, imageURL: imageURL, forceRefreshToken: true)
            return
        } catch {
            throw remapAPIError(error)
        }
        
        yardStorage.save(yardID: invite.yard.id)
        
        await MainActor.run {
            self.activeYardID = invite.yard.id
            self.pendingInvites.removeAll { $0.id == invite.id }
            self.errorMessage = nil
        }
    }
    
    func decline(invite: Invite, forceRefreshToken: Bool = false) async throws {
        let token = try await authService.getIDToken(forceRefresh: forceRefreshToken)
        
        do {
            _ = try await webService.sendRequest(
                toURL: "\(APIConfiguration.baseURL)/v2/invites/\(invite.id.uuidString)/reject",
                method: .post,
                headers: [
                    "Authorization": "Bearer \(token)",
                    "Accept": "application/json"
                ],
                body: nil,
                configureDecoder: decoderConfigurator
            ) as EmptyResponse
        } catch let NetworkError.badStatus(code, _) where code == 401 && !forceRefreshToken {
            try await decline(invite: invite, forceRefreshToken: true)
            return
        } catch {
            throw remapAPIError(error)
        }
        
        await MainActor.run {
            self.pendingInvites.removeAll { $0.id == invite.id }
            self.errorMessage = nil
        }
    }
    
    func clearStoredYard() {
        yardStorage.clearYardID()
        activeYardID = nil
    }
}

private struct AcceptInviteRequest: Encodable {
    let name: String
    let imageUrl: String?
}

private extension InviteService {
    func resolveName(for invite: Invite, overridingWith providedName: String?) -> String {
        if let provided = trimmedNonEmpty(providedName) {
            return provided
        }
        if let displayName = trimmedNonEmpty(authService.user?.displayName) {
            return displayName
        }
        if let email = trimmedNonEmpty(authService.user?.email) {
            return email
        }
        return invite.email
    }
    
    func trimmedNonEmpty(_ string: String?) -> String? {
        guard let raw = string?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return nil
        }
        return raw
    }
    
    func remapAPIError(_ error: Error) -> Error {
        guard case let NetworkError.badStatus(code, data) = error else {
            return error
        }
        
        if let message = InviteService.extractErrorMessage(from: data) {
            return InviteServiceError.api(message: message, statusCode: code)
        }
        
        return InviteServiceError.api(
            message: NSLocalizedString("The request failed.", comment: "Generic error message when a request fails without a status code."),
            statusCode: code
        )
    }
    
    static func extractErrorMessage(from data: Data?) -> String? {
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
        
        if let message = String(data: data, encoding: .utf8), !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return message
        }
        
        return nil
    }
}

private enum InviteServiceError: LocalizedError {
    case api(message: String, statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case let .api(message, statusCode):
            let format = NSLocalizedString(
                "%@ (code %lld)",
                comment: "API error with message and status code"
            )
            return String(format: format, message, Int64(statusCode))
        }
    }
}
