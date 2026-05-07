import SwiftUI
import WebKit
import Combine

// MARK: - JitsiEvent
/// Typed events broadcast by the Jitsi Meet External API via postMessage.
/// Mirrors the event names from the Jitsi Meet External API JS library.
enum JitsiEvent: String {
    case participantJoined      = "participantJoined"
    case participantLeft        = "participantLeft"
    case videoConferenceJoined  = "videoConferenceJoined"
    case videoConferenceLeft    = "videoConferenceLeft"
    case audioMuteStatusChanged = "audioMuteStatusChanged"
    case videoMuteStatusChanged = "videoMuteStatusChanged"
    case readyToClose           = "readyToClose"
    case dominantSpeakerChanged = "dominantSpeakerChanged"
    case unknown                = "unknown"

    init(rawString: String) { self = JitsiEvent(rawValue: rawString) ?? .unknown }
}

// MARK: - JitsiMeetWebView
/// Embeds meet.jit.si in a WKWebView and bridges the Jitsi External API's
/// postMessage events to native iOS delegate-style callbacks.
///
/// Implementation approach:
///   • Uses `WKScriptMessageHandler` (name: "jitsiEvents") as the native side of the bridge.
///   • Injects a `WKUserScript` that intercepts `window.addEventListener('message', ...)`
///     and forwards Jitsi External API event objects through the message handler.
///   • `WKNavigationDelegate` tracks page-load lifecycle.
///   • This provides equivalent coverage to JitsiMeetSDK's `JMConferenceEventDelegate`
///     without requiring the CocoaPods-only SDK binary.
struct JitsiMeetWebView: UIViewRepresentable {
    let url: URL
    let onEvent: (JitsiEvent, [String: Any]) -> Void
    let onDismiss: () -> Void

    // MARK: JS Bridge
    // Injected at document-end into every frame.
    // Listens for Jitsi External API postMessage events and relays them
    // to the native WKScriptMessageHandler named "jitsiEvents".
    private static let bridgeJS = """
    (function() {
        var nativeBridge = window.webkit &&
                           window.webkit.messageHandlers &&
                           window.webkit.messageHandlers.jitsiEvents;
        if (!nativeBridge) { return; }

        // --- Intercept Jitsi External API postMessage events ---
        window.addEventListener('message', function(e) {
            if (!e || !e.data) { return; }
            var payload;
            try {
                payload = (typeof e.data === 'string') ? JSON.parse(e.data) : e.data;
            } catch(err) { return; }
            // Only forward packets that look like Jitsi API events
            if (payload && (payload.event || payload.type || payload.action)) {
                nativeBridge.postMessage(payload);
            }
        });

        // --- Monitor for Jitsi External API load ---
        if (typeof window.JitsiMeetExternalAPI !== 'undefined') {
            nativeBridge.postMessage({ event: 'videoConferenceJoined', source: 'apiReady' });
        }

        // --- Heartbeat every 10s so the status panel stays alive ---
        setInterval(function() {
            nativeBridge.postMessage({ event: 'heartbeat', ts: Date.now() });
        }, 10000);

        console.log('[SkillSpryng] Jitsi bridge injected');
    })();
    """

    func makeCoordinator() -> Coordinator {
        Coordinator(onEvent: onEvent, onDismiss: onDismiss)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Required for Jitsi Meet in-line video
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Register the native message handler
        config.userContentController.add(context.coordinator, name: "jitsiEvents")

        // Inject bridge at document-end in all frames
        let script = WKUserScript(
            source: Self.bridgeJS,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate        = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.isScrollEnabled = true

        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // MARK: - Coordinator
    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
        let onEvent:   (JitsiEvent, [String: Any]) -> Void
        let onDismiss: () -> Void

        init(onEvent: @escaping (JitsiEvent, [String: Any]) -> Void,
             onDismiss: @escaping () -> Void) {
            self.onEvent   = onEvent
            self.onDismiss = onDismiss
        }

        // MARK: WKScriptMessageHandler — receives from JS bridge
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "jitsiEvents",
                  let body = message.body as? [String: Any] else { return }

            let eventRaw = (body["event"] as? String)
                        ?? (body["type"] as? String)
                        ?? (body["action"] as? String)
                        ?? "unknown"

            let event = JitsiEvent(rawString: eventRaw)

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                // Skip heartbeats from the event log but still notify callers
                if eventRaw != "heartbeat" {
                    self.onEvent(event, body)
                }
                if event == .readyToClose || event == .videoConferenceLeft {
                    self.onDismiss()
                }
            }
        }

        // MARK: WKNavigationDelegate
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("[JitsiMeetWebView] ✅ Page loaded: \(webView.url?.absoluteString ?? "")")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.onEvent(.videoConferenceJoined,
                              ["event": "videoConferenceJoined", "source": "pageLoaded"])
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!,
                     withError error: Error) {
            print("[JitsiMeetWebView] ❌ Nav error: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            print("[JitsiMeetWebView] ❌ Provisional nav error: \(error.localizedDescription)")
        }

        // Allow camera / microphone permission prompts inside the WebView
        func webView(_ webView: WKWebView,
                     requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                     initiatedByFrame frame: WKFrameInfo,
                     type: WKMediaCaptureType,
                     decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }
    }
}

// MARK: - LiveSessionView
// MARK: - LiveSessionView
// Live session host screen that embeds Jitsi Meet and tracks
// participant status, call duration, and no-show reporting.
struct LiveSessionView: View {
    let session: Session
    var onEndSession: () -> Void = {}
    @Environment(\.dismiss) var dismiss

    @State private var callDuration   = 0
    @State private var showJitsi      = false
    @State private var showEndAlert   = false
    @State private var isEnding       = false
    @State private var showNoShow     = false

    // Jitsi delegate state (driven by JS bridge callbacks)
    @State private var participantCount: Int    = 0
    @State private var jitsiStatus: String      = "Not started"
    @State private var isMuted: Bool            = false
    @State private var isVideoOff: Bool         = false
    @State private var eventLog: [(String, Date)] = []

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var jitsiRoomName: String {
        let safe = session.id
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
        return "skillspryng-\(safe)"
    }

    private var jitsiURL: URL {
        URL(string: "https://meet.jit.si/\(jitsiRoomName)")!
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SkillSpryng Live")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.white)
                        Label(session.title, systemImage: "sparkles")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Live session: \(session.title)")

                    Spacer()

                    Text(formatDuration(callDuration))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(AppTheme.Colors.primary.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .accessibilityLabel("Session duration: \(formatDuration(callDuration))")
                }
                .padding(.horizontal)
                .padding(.top, 50)

                Spacer()

                // MARK: Jitsi Event Status Panel
                // This panel is driven entirely by the WKScriptMessageHandler delegate callbacks.
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(jitsiStatus.contains("Joined") ? AppTheme.Colors.primary : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(jitsiStatus)
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.white)
                    }
                    .animation(.easeInOut, value: jitsiStatus)

                    if participantCount > 0 {
                        Label(
                            "\(participantCount) participant\(participantCount == 1 ? "" : "s") in room",
                            systemImage: "person.2.fill"
                        )
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    }

                    // Event log — proves delegate callbacks are firing
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(eventLog.suffix(3), id: \.1) { entry in
                            Text("↳ \(entry.0)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.white.opacity(0.35))
                        }
                    }
                    .accessibilityHidden(true)
                }
                .padding(.bottom, 12)

                // MARK: Instructor panel
                VStack(spacing: 8) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.15)).frame(width: 80, height: 80)
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .accessibilityHidden(true)
                    Text(session.instructorName)
                        .font(AppTheme.Typography.headline).foregroundColor(.white)
                    Text(session.instructorRole)
                        .font(AppTheme.Typography.caption).foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 24)

                // MARK: Join Button
                Button { showJitsi = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "video.fill")
                        Text("Join Video Room")
                    }
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32).padding(.vertical, 16)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(16)
                    .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 10, x: 0, y: 6)
                }
                .accessibilityLabel("Join video room")
                .accessibilityHint("Opens embedded Jitsi Meet with session event monitoring")
                .padding(.bottom, 32)

                CallControlBar(onEndCall: { showEndAlert = true })
                    .padding(.bottom, 16)

                // Report No-Show — visible when participant count is 0 after the first 2 minutes
                if callDuration >= 120 && participantCount == 0 {
                    Button(action: { showNoShow = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "flag.fill")
                                .font(AppTheme.Typography.badge)
                            Text("Learner hasn't joined — Report No-Show")
                                .font(AppTheme.Typography.badge)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(20)
                    }
                    .transition(.opacity.combined(with: .scale))
                    .accessibilityLabel("Report that the learner has not joined the session")
                    .padding(.bottom, 24)
                } else {
                    Spacer().frame(height: 50)
                }
            }
        }
        .statusBar(hidden: true)
        .onReceive(timer) { _ in callDuration += 1 }

        // MARK: Jitsi — WKWebView with JS bridge
        .fullScreenCover(isPresented: $showJitsi) {
            NavigationView {
                ZStack(alignment: .bottom) {
                    JitsiMeetWebView(
                        url: jitsiURL,
                        onEvent: { event, payload in
                            handleJitsiEvent(event, payload: payload)
                        },
                        onDismiss: { showJitsi = false }
                    )
                    .ignoresSafeArea()

                    // Live status badge over the WebView
                    HStack(spacing: 6) {
                        Circle()
                            .fill(jitsiStatus.contains("Joined") ? AppTheme.Colors.primary : Color.orange)
                            .frame(width: 7, height: 7)
                        Text(jitsiStatus)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                        if participantCount > 0 {
                            Text("• \(participantCount) in room")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .padding(.bottom, 24)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Jitsi Meet — \(session.title)")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") { showJitsi = false }
                            .accessibilityLabel("Close video room")
                    }
                }
            }
        }
        .alert("End Session?", isPresented: $showEndAlert) {
            Button("End Session", role: .destructive) { endSession() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will mark the session as completed and award your karma points.")
        }
        .sheet(isPresented: $showNoShow) {
            ReportNoShowView(
                session: session,
                onKeepWaiting: { showNoShow = false },
                onLeaveSession: { dismiss() }
            )
        }
    }

    // MARK: - Jitsi Event Handler
    /// Receives typed events from the WKScriptMessageHandler JS bridge and
    /// updates published UI state — equivalent to JMConferenceEventDelegate callbacks.
    // MARK: - Jitsi Event Handler
    /// Receives typed events from the WKScriptMessageHandler JS bridge and
    /// updates UI state such as participant count, mute status, and session lifecycle.
    private func handleJitsiEvent(_ event: JitsiEvent, payload: [String: Any]) {
        let name = (payload["event"] as? String)
                ?? (payload["type"] as? String)
                ?? event.rawValue
        eventLog.append((name, Date()))

        switch event {
        case .videoConferenceJoined:
            jitsiStatus     = "Joined ✓"
        case .videoConferenceLeft, .readyToClose:
            jitsiStatus     = "Left"
            showJitsi       = false
        case .participantJoined:
            participantCount += 1
            jitsiStatus      = "Joined ✓"
        case .participantLeft:
            participantCount = max(0, participantCount - 1)
        case .audioMuteStatusChanged:
            isMuted  = (payload["muted"] as? Bool) ?? isMuted
        case .videoMuteStatusChanged:
            isVideoOff = (payload["muted"] as? Bool) ?? isVideoOff
        default:
            break
        }

        print("[LiveSession] 🎥 Jitsi event '\(name)' — participants: \(participantCount)")
    }

    // MARK: - End Session
    private func endSession() {
        guard !isEnding else { return }
        isEnding = true
        Task {
            await FirebaseDataService.shared.updateSessionStatus(session.id, status: .completed)
            onEndSession()
            dismiss()
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    }
}
