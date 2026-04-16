import SwiftUI
import AVFoundation
import UIKit
import Combine

// MARK: - CameraController
/// ObservableObject that owns the AVCaptureSession lifecycle and exposes capture/flip actions.
/// Used by AVCameraPreviewView (UIViewRepresentable) and CameraSheetView (SwiftUI).
///
/// AVFoundation components:
///   • AVCaptureSession         — orchestrates camera data flow
///   • AVCaptureDevice          — accesses front/rear camera hardware
///   • AVCaptureDeviceInput     — connects device to the session
///   • AVCapturePhotoOutput     — captures still JPEG images
///   • AVCaptureVideoPreviewLayer — renders the live viewfinder feed
@MainActor
final class CameraController: NSObject, ObservableObject {

    // MARK: - Published State
    @Published var capturedImage: UIImage?
    @Published var isRunning: Bool = false
    @Published var permissionDenied: Bool = false
    @Published var currentPosition: AVCaptureDevice.Position = .front

    // MARK: - AVFoundation Session
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?

    // MARK: - Setup
    func start() {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            // Check permission
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .notDetermined:
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                if !granted { await MainActor.run { self.permissionDenied = true }; return }
            case .denied, .restricted:
                await MainActor.run { self.permissionDenied = true }
                return
            default: break
            }

            await self.configureSession(position: self.currentPosition)
        }
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
        isRunning = false
    }

    // MARK: - Capture
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
        print("[CameraController] 📸 capturePhoto() called")
    }

    // MARK: - Flip
    func flipCamera() {
        currentPosition = currentPosition == .front ? .back : .front
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            await self.configureSession(position: self.currentPosition)
        }
    }

    // MARK: - Private

    private func configureSession(position: AVCaptureDevice.Position) async {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Remove existing inputs
        if let existing = currentInput { session.removeInput(existing) }

        // Resolve device
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: position
        ) ?? AVCaptureDevice.default(for: .video) else {
            session.commitConfiguration()
            print("[CameraController] ❌ No camera available for position \(position.rawValue)")
            return
        }

        // Create and add input
        guard let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        currentInput = input

        // Add photo output if not already present
        if session.outputs.isEmpty, session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()

        if !session.isRunning {
            session.startRunning()
        }

        await MainActor.run {
            self.isRunning = true
            print("[CameraController] ✅ AVCaptureSession running — position: \(position == .front ? "front" : "back")")
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                 didFinishProcessingPhoto photo: AVCapturePhoto,
                                 error: Error?) {
        if let error {
            print("[CameraController] ❌ Photo error: \(error.localizedDescription)")
            return
        }
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }

        Task { @MainActor [weak self] in
            self?.capturedImage = image
            self?.stop()
            print("[CameraController] ✅ Photo captured: \(image.size)")
        }
    }
}

// MARK: - AVCameraPreviewView
/// UIkit view that hosts the AVCaptureVideoPreviewLayer over a given AVCaptureSession.
final class AVCameraPreviewView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var captureSession: AVCaptureSession? {
        get { (layer as? AVCaptureVideoPreviewLayer)?.session }
        set { (layer as? AVCaptureVideoPreviewLayer)?.session = newValue }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.frame = bounds
    }

    func configure(with session: AVCaptureSession) {
        guard let previewLayer = layer as? AVCaptureVideoPreviewLayer else { return }
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        print("[AVCameraPreviewView] ✅ Preview layer configured")
    }
}

// MARK: - AVCameraPreviewRepresentable
/// SwiftUI wrapper around AVCameraPreviewView.
struct AVCameraPreviewRepresentable: UIViewRepresentable {
    @ObservedObject var controller: CameraController

    func makeUIView(context: Context) -> AVCameraPreviewView {
        let view = AVCameraPreviewView()
        view.configure(with: controller.session)
        return view
    }

    func updateUIView(_ uiView: AVCameraPreviewView, context: Context) {}
}

// MARK: - CameraSheetView
/// Full-screen camera sheet presented in EditProfileView.
/// Shows a live AVFoundation camera preview with shutter & flip buttons.
struct CameraSheetView: View {
    @StateObject private var camera = CameraController()
    @Environment(\.dismiss) var dismiss

    var onImageCaptured: (UIImage) -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if camera.permissionDenied {
                permissionDeniedPlaceholder
            } else {
                // Live AVFoundation viewfinder
                AVCameraPreviewRepresentable(controller: camera)
                    .ignoresSafeArea()
                    .accessibilityLabel("Live camera preview")
            }

            VStack {
                // Top bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .accessibilityLabel("Close camera")
                    Spacer()
                    Text("Take Photo")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    // Balance spacer
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.top, 54)
                .padding(.horizontal, 20)

                Spacer()

                // Controls bar
                HStack(spacing: 60) {
                    // Flip camera
                    Button { camera.flipCamera() } label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    .accessibilityLabel("Flip camera")

                    // Shutter
                    Button {
                        camera.capturePhoto()
                    } label: {
                        ZStack {
                            Circle().stroke(Color.white.opacity(0.4), lineWidth: 3).frame(width: 82, height: 82)
                            Circle().fill(Color.white).frame(width: 68, height: 68)
                        }
                    }
                    .disabled(!camera.isRunning)
                    .accessibilityLabel("Capture photo")

                    // Right balance
                    Color.clear.frame(width: 56, height: 56)
                }
                .padding(.bottom, 60)
            }
        }
        .statusBar(hidden: true)
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
        .onChange(of: camera.capturedImage) { image in
            if let img = image {
                onImageCaptured(img)
                dismiss()
            }
        }
    }

    private var permissionDeniedPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48)).foregroundColor(.gray)
            Text("Camera Access Required")
                .font(.headline).foregroundColor(.white)
            Text("Go to Settings → Privacy → Camera to allow SkillSpryng to use the camera.")
                .font(.subheadline).foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.subheadline).foregroundColor(AppTheme.Colors.primary)
        }
    }
}
