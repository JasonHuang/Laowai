import AVFoundation
import Vision
import SwiftUI

struct RecognizedText: Identifiable {
    let id = UUID()
    let original: String
    var translation: String?
    let boundingBox: CGRect   // normalised Vision coords (origin bottom-left)
}

final class CameraViewModel: NSObject, ObservableObject {

    // MARK: - Published (always updated on main)
    @Published var recognizedTexts: [RecognizedText] = []
    @Published var permissionGranted = false
    @Published var isScanning = false

    // MARK: - Camera (nonisolated)
    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session")

    // Rate limiting — accessed only on sessionQueue
    private var lastFrameTime = Date.distantPast
    private let frameInterval: TimeInterval = 1.5

    // MARK: - Permission

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { self.permissionGranted = true }
            sessionQueue.async { self.configureSession() }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { self.permissionGranted = granted }
                if granted { self.sessionQueue.async { self.configureSession() } }
            }
        default:
            DispatchQueue.main.async { self.permissionGranted = false }
        }
    }

    // MARK: - Session (call on sessionQueue)

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .hd1280x720

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { session.commitConfiguration(); return }

        session.addInput(input)
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }
        session.commitConfiguration()
    }

    func startSession() {
        DispatchQueue.main.async { self.isScanning = true }
        sessionQueue.async {
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    func stopSession() {
        DispatchQueue.main.async { self.isScanning = false }
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    func captureCurrentFrame() {
        DispatchQueue.main.async { self.isScanning = false }
        sessionQueue.async { self.session.stopRunning() }
    }

    func resumeScanning() {
        DispatchQueue.main.async { self.recognizedTexts = [] }
        startSession()
    }

    // MARK: - Vision OCR (runs on sessionQueue)

    private func recognizeText(in sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNRecognizeTextRequest { [weak self] req, _ in
            guard let self,
                  let observations = req.results as? [VNRecognizedTextObservation] else { return }
            let texts = observations.compactMap { obs -> RecognizedText? in
                guard let top = obs.topCandidates(1).first,
                      top.confidence > 0.4,
                      Self.containsChinese(top.string) else { return nil }
                return RecognizedText(original: top.string, boundingBox: obs.boundingBox)
            }
            guard !texts.isEmpty else { return }
            DispatchQueue.main.async { self.recognizedTexts = texts }
        }
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
        try? handler.perform([request])
    }

    // MARK: - Helpers

    private static func containsChinese(_ string: String) -> Bool {
        string.unicodeScalars.contains {
            (0x4E00...0x9FFF).contains($0.value) ||
            (0x3400...0x4DBF).contains($0.value)
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let now = Date()
        guard now.timeIntervalSince(lastFrameTime) >= frameInterval else { return }
        lastFrameTime = now
        recognizeText(in: sampleBuffer)
    }
}
