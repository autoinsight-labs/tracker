//
//  VehicleCreateView.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 09/11/25.
//

import SwiftUI
import AVFoundation

struct VehicleCreateView: View {
    @Environment(VehicleService.self) private var vehicleService: VehicleService
    @Environment(\.dismiss) private var dismiss
    
    let yardID: UUID
    
    @State private var plate: String = ""
    @State private var model: Vehicle.Model = .mottuSport110i
    @State private var employees: [YardEmployee] = []
    @State private var selectedAssigneeId: UUID?
    
    @State private var beaconUUID: String = ""
    @State private var beaconMajor: String = ""
    @State private var beaconMinor: String = ""
    
    @State private var isLoadingEmployees = true
    @State private var employeesError: String?
    
    @State private var isPresentingScanner = false
    @State private var scannerError: String?
    
    @State private var isSaving = false
    @State private var saveErrorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle information") {
                    TextField("Plate", text: $plate)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .textContentType(.none)
                    
                    Picker("Model", selection: $model) {
                        ForEach(Vehicle.Model.allCases, id: \.self) { model in
                            Text(model.displayName).tag(model)
                        }
                    }
                }
                
                Section("Beacon") {
                    if let scannerError {
                        Text(scannerError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    
                    Button {
                        handleScannerPermission()
                    } label: {
                        Label("Scan beacon QR code", systemImage: "qrcode.viewfinder")
                    }
                    
                    if !beaconUUID.isEmpty {
                        LabeledContent("UUID") {
                            Text(beaconUUID)
                                .font(.body.monospaced())
                                .foregroundStyle(.secondary)
                                .contextMenu {
                                    Button {
                                        UIPasteboard.general.string = beaconUUID
                                    } label: {
                                        Label("Copy UUID", systemImage: "doc.on.doc")
                                    }
                                }
                        }
                        LabeledContent("Major") {
                            Text(beaconMajor)
                                .foregroundStyle(.secondary)
                        }
                        LabeledContent("Minor") {
                            Text(beaconMinor)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Scan the beacon QR code to autofill the data.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Assignee") {
                    if isLoadingEmployees {
                        HStack {
                            ProgressView()
                            Text("Loading employees...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } else if let employeesError {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(employeesError)
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
            .navigationTitle(Text("New vehicle"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: handleSave)
                        .disabled(!isFormValid || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(24)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .alert(
                "Vehicle creation failed.",
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
            .task {
                await loadEmployees()
            }
            .sheet(isPresented: $isPresentingScanner) {
                QRCodeScannerView { result in
                    switch result {
                    case .success(let beacon):
                        beaconUUID = beacon.uuid.uuidString
                        beaconMajor = beacon.major
                        beaconMinor = beacon.minor
                        scannerError = nil
                    case .failure(let error):
                        scannerError = error.localizedDescription
                    }
                    isPresentingScanner = false
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        guard !plate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard let uuid = UUID(uuidString: beaconUUID.trimmingCharacters(in: .whitespacesAndNewlines)) else { return false }
        guard !beaconMajor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !beaconMinor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        _ = uuid // silence unused
        return true
    }
    
    private func handleSave() {
        guard isFormValid else { return }
        
        isSaving = true
        saveErrorMessage = nil
        
        let trimmedPlate = plate.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let trimmedUUID = beaconUUID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMajor = beaconMajor.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMinor = beaconMinor.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let uuid = UUID(uuidString: trimmedUUID) else {
            saveErrorMessage = String(localized: "The URL is invalid.")
            isSaving = false
            return
        }
        
        guard let majorInt = Int(trimmedMajor), let minorInt = Int(trimmedMinor) else {
            saveErrorMessage = String(localized: "The request failed.")
            isSaving = false
            return
        }
        
        let request = VehicleCreateRequest(
            plate: trimmedPlate,
            model: model,
            beacon: VehicleCreateRequest.Beacon(
                uuid: uuid,
                major: majorInt,
                minor: minorInt
            ),
            assigneeId: selectedAssigneeId
        )
        
        Task {
            do {
                _ = try await vehicleService.createVehicle(in: yardID, request: request)
                await vehicleService.fetchVehicles(for: yardID, forceRefresh: true)
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    saveErrorMessage = error.localizedDescription
                    isSaving = false
                }
            }
        }
    }
    
    private func loadEmployees() async {
        await MainActor.run {
            isLoadingEmployees = true
            employeesError = nil
        }
        
        do {
            let fetched = try await vehicleService.fetchEmployees(for: yardID)
            await MainActor.run {
                self.employees = fetched
                self.isLoadingEmployees = false
                if let selectedAssigneeId,
                   !fetched.contains(where: { $0.id == selectedAssigneeId }) {
                    self.selectedAssigneeId = nil
                }
            }
        } catch {
            await MainActor.run {
                employeesError = error.localizedDescription
                isLoadingEmployees = false
            }
        }
    }
    
    private func handleScannerPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            scannerError = nil
            isPresentingScanner = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    if granted {
                        scannerError = nil
                        isPresentingScanner = true
                    } else {
                        scannerError = String(localized: "Camera permission is required to scan the beacon.")
                    }
                }
            }
        case .denied, .restricted:
            scannerError = String(localized: "Camera permission is required to scan the beacon.")
        @unknown default:
            scannerError = String(localized: "Unable to access the camera for scanning.")
        }
    }
}

private struct QRBeaconPayload: Decodable {
    struct Beacon: Decodable {
        let uuid: UUID
        let major: String
        let minor: String
    }
    
    let beacon: Beacon
}

struct QRCodeScannerView: UIViewControllerRepresentable {
    enum ScannerError: LocalizedError {
        case invalidPayload
        case unsupportedCode
        case cameraUnavailable
        
        var errorDescription: String? {
            switch self {
            case .invalidPayload:
                return NSLocalizedString("The scanned QR code does not contain a valid beacon payload.", comment: "")
            case .unsupportedCode:
                return NSLocalizedString("The scanned code type is not supported.", comment: "")
            case .cameraUnavailable:
                return NSLocalizedString("Unable to access the camera for scanning.", comment: "")
            }
        }
    }
    
    struct BeaconResult {
        let uuid: UUID
        let major: String
        let minor: String
    }
    
    var onResult: (Result<BeaconResult, ScannerError>) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.delegate = context.coordinator
        controller.onCameraUnavailable = {
            context.coordinator.didEncounterCameraIssue()
        }
        context.coordinator.controller = controller
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        private let parent: QRCodeScannerView
        weak var controller: ScannerViewController?
        private var didEmitResult = false
        
        init(parent: QRCodeScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard !didEmitResult,
                  let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  metadata.type == .qr,
                  let stringValue = metadata.stringValue else {
                parent.onResult(.failure(.unsupportedCode))
                return
            }
            
            didEmitResult = true
            controller?.stopScanning()
            
            do {
                guard let data = stringValue.data(using: .utf8) else {
                    throw ScannerError.invalidPayload
                }
                
                if let payload = try? JSONDecoder().decode(QRBeaconPayload.self, from: data) {
                    let beacon = BeaconResult(
                        uuid: payload.beacon.uuid,
                        major: payload.beacon.major,
                        minor: payload.beacon.minor
                    )
                    parent.onResult(.success(beacon))
                } else if let beaconOnly = try? JSONDecoder().decode(QRBeaconPayload.Beacon.self, from: data) {
                    let beacon = BeaconResult(
                        uuid: beaconOnly.uuid,
                        major: beaconOnly.major,
                        minor: beaconOnly.minor
                    )
                    parent.onResult(.success(beacon))
                } else {
                    throw ScannerError.invalidPayload
                }
            } catch let error as ScannerError {
                parent.onResult(.failure(error))
            } catch {
                parent.onResult(.failure(.invalidPayload))
            }
        }
        
        func didEncounterCameraIssue() {
            guard !didEmitResult else { return }
            didEmitResult = true
            parent.onResult(.failure(.cameraUnavailable))
        }
    }
    
    final class ScannerViewController: UIViewController {
        fileprivate var delegate: AVCaptureMetadataOutputObjectsDelegate?
        var onCameraUnavailable: (() -> Void)?
        private let session = AVCaptureSession()
        private var previewLayer: AVCaptureVideoPreviewLayer?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .black
            configureSession()
        }
        
        private func configureSession() {
            guard let videoDevice = AVCaptureDevice.default(for: .video) else {
                onCameraUnavailable?()
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if session.canAddInput(videoInput) {
                    session.addInput(videoInput)
                }
                
                let metadataOutput = AVCaptureMetadataOutput()
                if session.canAddOutput(metadataOutput) {
                    session.addOutput(metadataOutput)
                    metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                    metadataOutput.metadataObjectTypes = [.qr]
                }
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = view.layer.bounds
                view.layer.addSublayer(previewLayer)
                self.previewLayer = previewLayer
                
                session.startRunning()
            } catch {
                onCameraUnavailable?()
            }
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            previewLayer?.frame = view.bounds
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if session.isRunning {
                session.stopRunning()
            }
        }
        
        func stopScanning() {
            if session.isRunning {
                session.stopRunning()
            }
        }
    }
}

