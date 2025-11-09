//
//  PendingInvitesView.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import SwiftUI

struct PendingInvitesView: View {
    @Environment(InviteService.self) private var inviteService: InviteService
    
    @State private var processingInvites: Set<UUID> = []
    @State private var actionError: ActionError?
    
    var body: some View {
        mainContent
            .navigationTitle("Pending invites")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if inviteService.isLoading {
                        ProgressView()
                    }
                }
            }
            .task {
                if inviteService.pendingInvites.isEmpty && !inviteService.isLoading {
                    await inviteService.fetchData()
                }
            }
            .alert(item: $actionError) { error in
                Alert(
                    title: Text("We couldn't finish that action"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if inviteService.pendingInvites.isEmpty {
            placeholderScrollView
        } else {
            invitesList
        }
    }
    
    private var invitesList: some View {
        List(inviteService.pendingInvites) { invite in
            inviteRow(for: invite)
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await inviteService.fetchData()
        }
    }
    
    private var placeholderScrollView: some View {
        ScrollView {
            VStack(spacing: 16) {
                placeholderContent
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 24)
            .padding(.top, 80)
        }
        .refreshable {
            await inviteService.fetchData()
        }
    }
    
    @ViewBuilder
    private var placeholderContent: some View {
        if inviteService.isLoading {
            ProgressView()
            Text("Loading your invites...")
                .font(.callout)
                .foregroundStyle(.secondary)
        } else if let error = inviteService.errorMessage {
            Text("We couldn't load your invites.")
                .font(.headline)
            Text(error)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again") {
                Task {
                    await inviteService.fetchData()
                }
            }
            .buttonStyle(.borderedProminent)
        } else {
            Text("You don't have any pending invites.")
                .font(.headline)
            Text("Ask a yard admin to send you a new invite.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private func inviteRow(for invite: Invite) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(invite.yard.name)
                .font(.headline)
            
            roleAndDate(for: invite)
            
            if processingInvites.contains(invite.id) {
                HStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Processing...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack(spacing: 12) {
                    Button(role: .destructive) {
                        handleDecline(invite)
                    } label: {
                        Text("Decline")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Button {
                        handleAccept(invite)
                    } label: {
                        Text("Accept")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func handleAccept(_ invite: Invite) {
        Task {
            updateProcessing(invite.id, isProcessing: true)
            do {
                try await inviteService.accept(invite: invite)
            } catch {
                await MainActor.run {
                    self.actionError = ActionError(message: error.localizedDescription)
                }
            }
            updateProcessing(invite.id, isProcessing: false)
        }
    }
    
    private func handleDecline(_ invite: Invite) {
        Task {
            updateProcessing(invite.id, isProcessing: true)
            do {
                try await inviteService.decline(invite: invite)
            } catch {
                await MainActor.run {
                    self.actionError = ActionError(message: error.localizedDescription)
                }
            }
            updateProcessing(invite.id, isProcessing: false)
        }
    }
    
    @MainActor
    private func updateProcessing(_ id: UUID, isProcessing: Bool) {
        if isProcessing {
            processingInvites.insert(id)
        } else {
            processingInvites.remove(id)
        }
    }
    
    @ViewBuilder
    private func roleAndDate(for invite: Invite) -> some View {
        HStack(spacing: 12) {
            Label(invite.role, systemImage: "person.crop.circle.badge.checkmark")
            Label(invite.createdAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
    }
    
    private struct ActionError: Identifiable {
        let id = UUID()
        let message: String
    }
}

