//
//  VehicleDetailView.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import SwiftUI

struct VehicleDetailView: View {
    @Environment(VehicleService.self) private var vehicleService: VehicleService
    @Environment(\.dismiss) private var dismiss
    
    let yardID: UUID
    let vehicleID: UUID
    
    @State private var detail: VehicleDetail?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isSaving = false
    @State private var saveErrorMessage: String?
    
    @State private var selectedStatus: Vehicle.Status = .scheduled
    @State private var employees: [YardEmployee] = []
    @State private var isLoadingEmployees = true
    @State private var employeesError: String?
    @State private var selectedAssigneeId: UUID?
    @State private var beaconUUIDInput: String = ""
    @State private var beaconMajorInput: String = ""
    @State private var beaconMinorInput: String = ""
    
    var body: some View {
        content
            .navigationTitle(Text("Vehicle details"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save", action: handleSave)
                            .disabled(!hasChanges || isSaving || detail == nil)
                    }
                }
            }
            .alert(
                "Vehicle update failed.",
                isPresented: Binding(
                    get: { saveErrorMessage != nil },
                    set: { if !$0 { saveErrorMessage = nil } }
                ),
                presenting: saveErrorMessage
            ) { _ in
                Button("OK", role: .cancel) { }
            } message: { message in
                Text(message)
            }
            .task(id: vehicleID) {
                await loadDetail()
                let hasDetail = await MainActor.run { self.detail != nil }
                if hasDetail {
                    await loadEmployees()
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if isLoading {
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading vehicle details...")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage {
            VStack(spacing: 12) {
                Text(errorMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await loadDetail() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let detail {
            let trackerData = trackerDestination(for: detail)
            
            ZStack(alignment: .bottomTrailing) {
                Form {
                    detailsSection(detail)
                    assigneeSection(detail)
                    beaconSection(detail)
                }
                if let trackerData {
                    NavigationLink {
                        TrackerView(
                            uuid: trackerData.uuid,
                            major: trackerData.major,
                            minor: trackerData.minor,
                            vehicleId: detail.plate
                        )
                    } label: {
                        Image(systemName: "location.fill")
                            .padding(16)
                            .glassEffect()
                    }
                    .padding(12)
                }
            }
        }
    }
    
    private func detailsSection(_ detail: VehicleDetail) -> some View {
        Section("Details") {
            LabeledContent("Plate", value: detail.plate)
            LabeledContent("Model", value: detail.model.displayName)
            
            Picker("Status", selection: $selectedStatus) {
                ForEach(Vehicle.Status.allCases, id: \.self) { status in
                    Text(status.displayName).tag(status)
                }
            }
            .pickerStyle(.menu)
            
            LabeledContent("Entered at") {
                Text(Self.dateFormatter.string(from: detail.enteredAt))
                    .foregroundStyle(.secondary)
            }
            
            LabeledContent("Left at") {
                if let leftAt = detail.leftAt {
                    Text(Self.dateFormatter.string(from: leftAt))
                        .foregroundStyle(.secondary)
                } else {
                    Text("No departure recorded")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func assigneeSection(_ detail: VehicleDetail) -> some View {
        Section("Assignee") {
            if isLoadingEmployees {
                HStack {
                    ProgressView()
                    Text("Loading employees...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else if employeesError != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("We couldn't load the employees list.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        Task { await loadEmployees() }
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                Picker("Assignee", selection: $selectedAssigneeId) {
                    Text("No assignee").tag(UUID?.none)
                    ForEach(employees) { employee in
                        Text(employee.name).tag(employee.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    
    private func beaconSection(_ detail: VehicleDetail) -> some View {
        Section("Beacon") {
            TextField("UUID", text: $beaconUUIDInput)
                .textContentType(.none)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
            
            TextField("Major", text: $beaconMajorInput)
                .keyboardType(.numberPad)
            
            TextField("Minor", text: $beaconMinorInput)
                .keyboardType(.numberPad)
        }
    }
    
    private func loadDetail() async {
        isLoading = true
        errorMessage = nil
        do {
            let loaded = try await vehicleService.fetchVehicleDetail(for: yardID, vehicleID: vehicleID)
            await MainActor.run {
                self.detail = loaded
                self.selectedStatus = loaded.status
                self.selectedAssigneeId = loaded.assignee?.id
                self.beaconUUIDInput = loaded.beacon?.uuid.uuidString ?? ""
                self.beaconMajorInput = loaded.beacon?.major ?? ""
                self.beaconMinorInput = loaded.beacon?.minor ?? ""
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func loadEmployees() async {
        await MainActor.run {
            self.isLoadingEmployees = true
            self.employeesError = nil
        }
        
        do {
            let fetched = try await vehicleService.fetchEmployees(for: yardID)
            await MainActor.run {
                self.employees = fetched
                self.isLoadingEmployees = false
                if let current = self.selectedAssigneeId,
                   !fetched.contains(where: { $0.id == current }) {
                    self.selectedAssigneeId = nil
                }
            }
        } catch {
            await MainActor.run {
                self.employeesError = error.localizedDescription
                self.isLoadingEmployees = false
            }
        }
    }
    
    private func handleSave() {
        guard let detail else { return }
        
        if let beaconInput = trimmedBeaconUUID, UUID(uuidString: beaconInput) == nil {
            saveErrorMessage = String(localized: "The URL is invalid.")
            return
        }
        
        let update = VehicleUpdateRequest(
            status: selectedStatus != detail.status ? selectedStatus : nil,
            assigneeId: assigneeUUIDIfChanged(from: detail),
            beacon: beaconPayloadIfChanged(from: detail)
        )
        
        if update.status == nil, update.assigneeId == nil, update.beacon == nil {
            return
        }
        
        isSaving = true
        saveErrorMessage = nil
        
        Task {
            do {
                let updated = try await vehicleService.updateVehicle(
                    yardID: yardID,
                    vehicleID: vehicleID,
                    update: update
                )
                await vehicleService.fetchVehicles(for: yardID, forceRefresh: true)
                await MainActor.run {
                    self.detail = updated
                    self.selectedStatus = updated.status
                    self.selectedAssigneeId = updated.assignee?.id
                    self.beaconUUIDInput = updated.beacon?.uuid.uuidString ?? ""
                    self.beaconMajorInput = updated.beacon?.major ?? ""
                    self.beaconMinorInput = updated.beacon?.minor ?? ""
                    self.isSaving = false
                }
            } catch {
                await MainActor.run {
                    self.saveErrorMessage = error.localizedDescription
                    self.isSaving = false
                }
            }
        }
        
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            await loadDetail()
        }
    }
    
    private var hasChanges: Bool {
        guard let detail else { return false }
        
        if detail.status != selectedStatus {
            return true
        }
        
        if assigneeUUIDIfChanged(from: detail) != nil {
            return true
        }
        
        if beaconPayloadIfChanged(from: detail) != nil {
            return true
        }
        
        return false
    }
    
    private var trimmedBeaconUUID: String? {
        let trimmed = beaconUUIDInput.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    private func assigneeUUIDIfChanged(from detail: VehicleDetail) -> UUID? {
        let original = detail.assignee?.id
        return original != selectedAssigneeId ? selectedAssigneeId : nil
    }
    
    private func beaconPayloadIfChanged(from detail: VehicleDetail) -> VehicleUpdateRequest.Beacon? {
        let trimmedUUID = trimmedBeaconUUID
        let trimmedMajor = beaconMajorInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMinor = beaconMinorInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedUUID == nil, trimmedMajor.isEmpty, trimmedMinor.isEmpty {
            return nil
        }
        
        guard
            let uuidString = trimmedUUID,
            let uuid = UUID(uuidString: uuidString),
            !trimmedMajor.isEmpty,
            !trimmedMinor.isEmpty
        else {
            return nil
        }
        
        let original = detail.beacon
        let hasChanged = original?.uuid != uuid ||
                         original?.major != trimmedMajor ||
                         original?.minor != trimmedMinor
        
        if hasChanged {
            return VehicleUpdateRequest.Beacon(
                uuid: uuid,
                major: trimmedMajor,
                minor: trimmedMinor
            )
        }
        
        return nil
    }
    
    private func trackerDestination(for detail: VehicleDetail) -> (uuid: UUID, major: UInt16, minor: UInt16)? {
        guard
            let beacon = detail.beacon,
            let major = beacon.majorAsUInt16,
            let minor = beacon.minorAsUInt16
        else {
            return nil
        }
        
        return (beacon.uuid, major, minor)
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
