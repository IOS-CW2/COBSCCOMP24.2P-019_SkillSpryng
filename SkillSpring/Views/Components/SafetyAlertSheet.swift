import SwiftUI
import Combine

/// Shown as a fullScreenCover when GeofenceManager detects the user
/// has moved outside the 100m session venue boundary.
struct SafetyAlertSheet: View {

    // MARK: - Input
    let sessionTitle: String

    // MARK: - Callbacks
    var onImFine: () -> Void
    var onNeedHelp: () -> Void

    // MARK: - Timer state
    /// Countdown from 5 minutes (300 seconds)
    @State private var secondsRemaining: Int = 300
    @State private var expired: Bool = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Derived values
    private var minutes: Int { secondsRemaining / 60 }
    private var seconds: Int { secondsRemaining % 60 }
    private var progress: Double { Double(secondsRemaining) / 300.0 }

    var body: some View {
        ZStack {
            // Blurred map background feel
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {

                    // Warning icon
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 72, height: 72)
                        Image(systemName: "exclamationmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.orange)
                    }
                    .padding(.top, 8)

                    // Heading & body
                    VStack(spacing: 10) {
                        Text("Are you still at your session?")
                            .font(.system(size: 22, weight: .bold))
                            .multilineTextAlignment(.center)

                        Text("We noticed you've moved outside the session geofence. Please confirm your safety within the next 5 minutes.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }

                    // Countdown ring
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 6)
                            .frame(width: 100, height: 100)

                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(
                                expired ? Color.red : AppTheme.Colors.primary,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: secondsRemaining)

                        Text(expired ? "TIME'S UP" : String(format: "%d:%02d", minutes, seconds))
                            .font(.system(size: expired ? 12 : 22, weight: .bold, design: .monospaced))
                            .foregroundColor(expired ? .red : .primary)
                    }

                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: onImFine) {
                            Text("Yes, I'm Fine")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.Colors.primary)
                                .cornerRadius(14)
                        }

                        Button(action: onNeedHelp) {
                            Text("I Need Help")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.08))
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red, lineWidth: 1.5))
                        }
                    }

                    // Footer warning
                    Text("If no response is received, we will automatically notify your emergency contacts and local authorities.")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                }
                .padding(28)
                .background(Color.white)
                .cornerRadius(32)
                .shadow(color: .black.opacity(0.18), radius: 30, y: 10)
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onReceive(timer) { _ in
            guard !expired else { return }
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                expired = true
                // Auto-fire "I Need Help" when countdown hits zero
                HapticManager.error()
                onNeedHelp()
            }
        }
    }
}
