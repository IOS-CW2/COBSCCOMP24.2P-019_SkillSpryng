import SwiftUI
import Combine

struct LiveSessionView: View {
    let session: Session
    @Environment(\.dismiss) var dismiss
    @State private var callDuration = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Main Video (Background)
            Image("instructor1")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.1))
                .accessibilityHidden(true)
            
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SkillSpryng")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Label(session.title, systemImage: "sparkles")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .accessibilityElement(children: .combine)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        // Timer
                        Text(formatDuration(callDuration))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .accessibilityLabel("Call duration: \(formatDuration(callDuration))")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 40)
                
                Spacer()
                
                // Participant overlay
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        ZStack(alignment: .bottomLeading) {
                            Image("instructor2")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 140)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
                            
                            HStack {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 8))
                                Text("You")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(6)
                            .padding(8)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Participant: You. Microphone active.")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Controls
                CallControlBar(onEndCall: { dismiss() })
                    .padding(.bottom, 40)
            }
        }
        .statusBar(hidden: true)
        .onReceive(timer) { _ in
            callDuration += 1
        }
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

