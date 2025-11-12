//
//  CameraCaptureView.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 12-11-25.
//

import AVFoundation
import SwiftUI

/// A view for capturing photos using the device camera (iOS 13+ compatible)
struct CameraCaptureView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var camera: CameraViewModel
    let onCapture: (UIImage) -> Void

    init(onCapture: @escaping (UIImage) -> Void) {
        self.onCapture = onCapture
        self.camera = CameraViewModel()
    }

    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(session: camera.session)
                .edgesIgnoringSafeArea(.all)
                .opacity(camera.isLoading ? 0 : 1)

            // Loading indicator
            if camera.isLoading {
                VStack(spacing: 16) {
                    ActivityIndicator(color: .white)
                    Text("Loading camera...")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }
            }

            // Error message
            if let error = camera.errorMessage {
                VStack(spacing: 16) {
                    Text("Camera Error")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                    Text(error)
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                            .foregroundColor(.black)
                            .font(.system(size: 12))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                }
            }

            // Controls overlay
            if camera.errorMessage == nil {
                VStack {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(16)
                    }

                    Spacer()

                    // Capture button
                    if !camera.isLoading {
                        Button(action: {
                            camera.capturePhoto { image in
                                if let image = image {
                                    onCapture(image)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16))
                                Text("Capture Photo")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(24)
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .background(Color.black)
        .onAppear {
            camera.checkPermissions()
        }
        .onDisappear {
            camera.stopSession()
        }
    }
}

/// Camera preview view
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(
        _ uiView: UIView,
        context: Context
    ) {
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

/// ViewModel for camera operations
class CameraViewModel: NSObject, ObservableObject {
    @Published var isLoading = true
    @Published var errorMessage: String?

    let session = AVCaptureSession()
    private var output = AVCapturePhotoOutput()
    private var captureCompletion: ((UIImage?) -> Void)?

    override init() {
        super.init()
    }

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.errorMessage = "Camera permission denied. Please allow camera access to take photos."
                        self?.isLoading = false
                    }
                }
            }
        case .denied, .restricted:
            errorMessage = "Camera permission denied. Please allow camera access in Settings."
            isLoading = false
        @unknown default:
            errorMessage = "Unable to access camera. Please try again."
            isLoading = false
        }
    }

    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Add video input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device)
        else {
            errorMessage = "No camera found on this device."
            isLoading = false
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        // Add photo output
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()

        // Start session on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }
    }

    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
            }
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        captureCompletion = completion

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto

        output.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.captureCompletion?(nil)
                self?.captureCompletion = nil
            }
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData)
        else {
            DispatchQueue.main.async { [weak self] in
                self?.captureCompletion?(nil)
                self?.captureCompletion = nil
            }
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.captureCompletion?(image)
            self?.captureCompletion = nil
        }
    }
}
