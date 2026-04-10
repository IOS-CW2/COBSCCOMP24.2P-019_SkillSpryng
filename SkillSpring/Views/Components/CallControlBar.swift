import SwiftUI

struct CallControlBar: View {
    @State private var isMuted = false
    @State private var isVideoOn = true
    @State private var isHandRaised = false
    var onEndCall: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            ControlCircleButton(icon: isMuted ? "mic.slash.fill" : "mic.fill", color: isMuted ? .red : .white.opacity(0.1)) {
                isMuted.toggle()
            }
            
            ControlCircleButton(icon: isVideoOn ? "video.fill" : "video.slash.fill", color: isVideoOn ? .white.opacity(0.1) : .red) {
                isVideoOn.toggle()
            }
            
            ControlCircleButton(icon: isHandRaised ? "hand.raised.fill" : "hand.raised", color: isHandRaised ? .teal : .teal.opacity(0.2)) {
                isHandRaised.toggle()
            }
            
            ControlCircleButton(icon: "bubble.left.fill", color: .white.opacity(0.1)) { }
            
            ControlCircleButton(icon: "phone.down.fill", color: .red, isLarge: true) {
                onEndCall()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.black.opacity(0.4))
        .clipShape(Capsule())
    }
}

struct ControlCircleButton: View {
    let icon: String
    let color: Color
    var isLarge: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: isLarge ? 56 : 44, height: isLarge ? 56 : 44)
                Image(systemName: icon)
                    .font(.system(size: isLarge ? 24 : 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
