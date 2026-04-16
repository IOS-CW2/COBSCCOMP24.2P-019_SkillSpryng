import SwiftUI
import SafariServices
import Combine

// MARK: - JitsiWebView
// Opens a real Jitsi Meet room in SFSafariViewController, embedded inside SwiftUI.
// Room name is derived from session.id to ensure each session has a unique URL.
// Full Jitsi Meet SDK integration would require a separate paid framework;
// this approach uses the free, publicly accessible meet.jit.si web service in a
// native in-app browser — giving genuine video calling without a custom SDK.

struct JitsiWebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = false
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredControlTintColor = UIColor(AppTheme.Colors.primary)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - LiveSessionView

struct LiveSessionView: View {
    let session: Session
    var onEndSession: () -> Void = {}
    @Environment(\.dismiss) var dismiss

    @State private var callDuration = 0
    @State private var showEndConfirmation = false
    @State private var isEndingSession = false
    @State private var showJitsi = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    /// Sanitised room name safe for a URL path segment.
    private var jitsiRoomName: String {
        let sanitised = session.id
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
        return "skillspryng-\(sanitised)"
    }

    private var jitsiURL: URL {
        URL(string: "https://meet.jit.si/\(jitsiRoomName)")!
    }

    var body: some View {
        ZStack {
            // Background — session colour
            LinearGradient(
                colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
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

                    // Timer badge
                    Text(formatDuration(callDuration))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .accessibilityLabel("Session duration: \(formatDuration(callDuration))")
                }
                .padding(.horizontal)
                .padding(.top, 50)

                Spacer()

                // MARK: Instructor info panel
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .accessibilityHidden(true)

                    Text(session.instructorName)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)

                    Text(session.instructorRole)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 24)

                // MARK: Open Jitsi button
                Button {
                    showJitsi = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "video.fill")
                        Text("Join Video Room")
                    }
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(16)
                    .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 10, x: 0, y: 6)
                }
                .accessibilityLabel("Join video room on Jitsi Meet")
                .accessibilityHint("Opens a video conference in the browser")
                .padding(.bottom, 32)

                // MARK: Controls
                CallControlBar(onEndCall: {
                    showEndConfirmation = true
                })
                .padding(.bottom, 50)
            }
        }
        .statusBar(hidden: true)
        .onReceive(timer) { _ in callDuration += 1 }
        // MARK: Jitsi Safari sheet
        .fullScreenCover(isPresented: $showJitsi) {
            NavigationView {
                JitsiWebView(url: jitsiURL)
                    .ignoresSafeArea()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Jitsi Meet")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") { showJitsi = false }
                                .accessibilityLabel("Close video room")
                        }
                    }
            }
        }
        // MARK: End session confirmation
        .alert("End Session?", isPresented: $showEndConfirmation) {
            Button("End Session", role: .destructive) {
                endSession()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will mark the session as completed and award your karma points.")
        }
    }

    // MARK: - End Session
    private func endSession() {
        guard !isEndingSession else { return }
        isEndingSession = true
        Task {
            await FirebaseDataService.shared.updateSessionStatus(session.id, status: .completed)
            onEndSession()
            dismiss()
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
