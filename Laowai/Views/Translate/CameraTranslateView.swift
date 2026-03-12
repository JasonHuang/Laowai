import SwiftUI
import AVFoundation
import Translation

struct CameraTranslateView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var showResults = false
    @State private var translationConfig: TranslationSession.Configuration?

    var body: some View {
        ZStack {
            Color(red: 0.031, green: 0.031, blue: 0.063).ignoresSafeArea()

            if viewModel.permissionGranted {
                cameraContent
            } else {
                permissionPrompt
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { viewModel.checkPermission() }
        .onDisappear { viewModel.stopSession() }
    }

    // MARK: - Camera content

    private var cameraContent: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Text("Translate")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                if !viewModel.recognizedTexts.isEmpty {
                    Button(action: { viewModel.resumeScanning() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Scan again")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(red: 0.902, green: 0.224, blue: 0.275))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 12)

            // Camera preview + overlay
            ZStack {
                CameraPreviewView(session: viewModel.session)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Bounding boxes overlay
                if !viewModel.recognizedTexts.isEmpty {
                    GeometryReader { geo in
                        ForEach(viewModel.recognizedTexts) { item in
                            let rect = visionRectToView(item.boundingBox, in: geo.size)
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(red: 0.957, green: 0.635, blue: 0.380), lineWidth: 2)
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.midX, y: rect.midY)
                        }
                    }
                }

                // Corner brackets when scanning
                if viewModel.isScanning && viewModel.recognizedTexts.isEmpty {
                    scannerBrackets
                }

                // Freeze button
                if viewModel.isScanning {
                    VStack {
                        Spacer()
                        Button(action: { viewModel.captureCurrentFrame() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 64, height: 64)
                                Circle()
                                    .fill(.white)
                                    .frame(width: 52, height: 52)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .frame(height: 380)
            .padding(.horizontal, 20)
            .onAppear { viewModel.startSession() }

            // Scanning hint or results
            if viewModel.recognizedTexts.isEmpty {
                scanHint
            } else {
                resultsList
            }

            Spacer()
        }
        .translationTask(translationConfig) { session in
            await runTranslation(session: session)
        }
    }

    // MARK: - Results list

    private var resultsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 4)
                    .padding(.vertical, 12)

                VStack(spacing: 10) {
                    ForEach(viewModel.recognizedTexts) { item in
                        ResultCard(item: item)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(maxHeight: 320)
        .onAppear {
            translationConfig = TranslationSession.Configuration(
                source: Locale.Language(identifier: "zh"),
                target: Locale.Language(identifier: "en")
            )
        }
    }

    private var scanHint: some View {
        VStack(spacing: 10) {
            Image(systemName: "text.viewfinder")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.3))
                .padding(.top, 32)
            Text("Point at Chinese text to translate")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.45))
            Text("Tap the shutter to freeze and read")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
    }

    // MARK: - Scanner brackets

    private var scannerBrackets: some View {
        Canvas { ctx, size in
            let pad: CGFloat = 40
            let len: CGFloat = 28
            let color = GraphicsContext.Shading.color(
                Color(red: 0.902, green: 0.224, blue: 0.275)
            )
            let style = StrokeStyle(lineWidth: 3, lineCap: .round)
            let corners: [(CGPoint, CGPoint, CGPoint)] = [
                // top-left
                (CGPoint(x: pad, y: pad + len), CGPoint(x: pad, y: pad), CGPoint(x: pad + len, y: pad)),
                // top-right
                (CGPoint(x: size.width - pad - len, y: pad), CGPoint(x: size.width - pad, y: pad), CGPoint(x: size.width - pad, y: pad + len)),
                // bottom-left
                (CGPoint(x: pad, y: size.height - pad - len), CGPoint(x: pad, y: size.height - pad), CGPoint(x: pad + len, y: size.height - pad)),
                // bottom-right
                (CGPoint(x: size.width - pad - len, y: size.height - pad), CGPoint(x: size.width - pad, y: size.height - pad), CGPoint(x: size.width - pad, y: size.height - pad - len)),
            ]
            for (a, b, c) in corners {
                var p = Path()
                p.move(to: a); p.addLine(to: b); p.addLine(to: c)
                ctx.stroke(p, with: color, style: style)
            }
        }
    }

    // MARK: - Permission prompt

    private var permissionPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color(red: 0.902, green: 0.224, blue: 0.275).opacity(0.7))

            Text("Camera Access Needed")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Laowai uses your camera to instantly translate Chinese menus, signs, and text.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)

            Button(action: openSettings) {
                Text("Open Settings")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.902, green: 0.224, blue: 0.275))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 40)
            }
        }
    }

    // MARK: - Translation task handler

    private func runTranslation(session: TranslationSession) async {
        let requests = viewModel.recognizedTexts.map {
            TranslationSession.Request(sourceText: $0.original, clientIdentifier: $0.id.uuidString)
        }
        do {
            let responses = try await session.translations(from: requests)
            var updated = viewModel.recognizedTexts
            for response in responses {
                if let idx = updated.firstIndex(where: { $0.id.uuidString == response.clientIdentifier }) {
                    updated[idx].translation = response.targetText
                }
            }
            await MainActor.run { viewModel.recognizedTexts = updated }
        } catch {
            // Translation failed silently — original text still shown
        }
    }

    // MARK: - Helpers

    private func visionRectToView(_ visionRect: CGRect, in size: CGSize) -> CGRect {
        // Vision origin is bottom-left; SwiftUI origin is top-left
        let x = visionRect.minX * size.width
        let y = (1 - visionRect.maxY) * size.height
        let w = visionRect.width * size.width
        let h = visionRect.height * size.height
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Result Card

private struct ResultCard: View {
    let item: RecognizedText

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.original)
                .font(.title3.bold())
                .foregroundStyle(.white)

            if let translation = item.translation {
                Text(translation)
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.957, green: 0.635, blue: 0.380))
            } else {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.white.opacity(0.4))
                    Text("Translating…")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Camera Preview (UIViewRepresentable)

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
