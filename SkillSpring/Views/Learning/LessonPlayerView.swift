import SwiftUI
import AVKit
import AVFoundation

// MARK: - LessonPlayerView
// Advanced iOS Feature: AVFoundation / AVKit media playback.
//
// AVFoundation components used:
//   • AVPlayer                  — controls playback of media resources
//   • AVPlayerViewController    — system playback UI (via AVKit's VideoPlayer)
//   • AVAsset                   — represents the media file / stream
//   • AVPlayerItem              — tracks playback progress
//
// For coursework: plays a real HLS stream (Apple sample) or a session recording URL.
// In production, the URL would come from FirebaseStorageService.uploadSessionRecording().

struct LessonPlayerView: View {
    let session: Session
    @Environment(\.dismiss) var dismiss

    @State private var currentLessonIndex = 3
    @State private var isPlaying = false
    @State private var playerProgress: Double = 0.0   // 0.0 – 1.0
    @State private var timeObserverToken: Any? = nil

    // MARK: AVPlayer setup
    // Apple public HLS test stream — valid, publicly available, no account required.
    // In production this would be: FirebaseStorageService.shared.fetchRecordingURL(sessionId:)
    private static let sampleStreamURL = URL(
        string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
    )!

    @State private var avPlayer: AVPlayer = AVPlayer(url: sampleStreamURL)
    @State private var playerError: String?

    var body: some View {
        VStack(spacing: 0) {

            // MARK: AVKit VideoPlayer — uses AVFoundation AVPlayer internally
            ZStack {
                Color.black

                VideoPlayer(player: avPlayer) {
                    // overlay content (shown whilst paused)
                    VStack {
                        HStack {
                            Button(action: {
                                avPlayer.pause()
                                dismiss()
                            }) {
                                Image(systemName: "chevron.down")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().fill(Color.black.opacity(0.3)))
                            }
                            .accessibilityLabel("Close lesson player")
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().fill(Color.black.opacity(0.3)))
                            }
                            .accessibilityLabel("Playback settings")
                        }
                        .padding(.top, 40)
                        .padding(.horizontal)
                        Spacer()
                    }
                }
                .onAppear {
                    // Start streaming automatically
                    avPlayer.play()
                    isPlaying = true
                    observePlayerErrors()
                    startProgressObserver()
                    print("[LessonPlayerView] ✅ AVPlayer started — URL: \(Self.sampleStreamURL)")
                }
                .onDisappear {
                    avPlayer.pause()
                    isPlaying = false
                    if let token = timeObserverToken {
                        avPlayer.removeTimeObserver(token)
                        timeObserverToken = nil
                    }
                }

                if let error = playerError {
                    Text("Playback error: \(error)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
            }
            .frame(height: 300)
            .ignoresSafeArea(edges: .top)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // Header info
                    VStack(alignment: .leading, spacing: 8) {
                        let progressPct = Int(playerProgress * 100)
                        Text("Lesson \(currentLessonIndex) of \(session.lessonCount ?? 0) — \(progressPct)% complete")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)

                        Text(session.title)
                            .font(.title3)
                            .fontWeight(.bold)

                        HStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(AppTheme.Colors.primary)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading) {
                                Text(session.instructorName)
                                    .font(AppTheme.Typography.badge)
                                Text(session.instructorRole)
                                    .font(AppTheme.Typography.caption2)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            StatusBadge(text: "Expert Mentor", color: .green)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Instructor: \(session.instructorName), \(session.instructorRole), Expert Mentor")
                    }
                    .padding(.top, 24)
                    .padding(.horizontal)

                    // Tabs
                    HStack(spacing: 24) {
                        TabHeader(title: "Lessons",   isSelected: true)
                        TabHeader(title: "Notes",     isSelected: false)
                        TabHeader(title: "Resources", isSelected: false)
                    }
                    .padding(.horizontal)

                    // Lesson List
                    VStack(spacing: 0) {
                        LessonPlaylistRow(index: 1, title: "The Digital Greenhouse Concept",  duration: "05:24", isCompleted: true)
                        LessonPlaylistRow(index: 2, title: "Understanding Tonal Depth",       duration: "08:12", isCompleted: true)
                        LessonPlaylistRow(index: 3, title: "Mastering Organic Layouts",       duration: "10:35", isCurrent: true)
                        LessonPlaylistRow(index: 4, title: "Asymmetry & Balance",             duration: "12:45")
                        LessonPlaylistRow(index: 5, title: "Dynamic Typography Scales",       duration: "09:30")
                    }
                    .padding(.horizontal)

                    Spacer().frame(height: 100)
                }
            }
            .background(Color.white)
            .cornerRadius(24)
            .offset(y: -20)

            // Bottom Action Bar
            HStack {
                Button(action: { seekBackward() }) {
                    Label("Previous", systemImage: "arrow.left")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.horizontal, 24).padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.Colors.primary.opacity(0.1), lineWidth: 1))
                }
                .accessibilityLabel("Go to previous lesson")

                Spacer()

                Button(action: { seekForward() }) {
                    HStack {
                        Text("Next Lesson")
                        Image(systemName: "arrow.right")
                    }
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24).padding(.vertical, 16)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(12)
                }
                .accessibilityLabel("Go to next lesson")
            }
            .padding(24)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Playback Controls

    private func seekForward() {
        let current = avPlayer.currentTime()
        avPlayer.seek(to: CMTime(seconds: current.seconds + 30, preferredTimescale: 600))
        currentLessonIndex = min(currentLessonIndex + 1, session.lessonCount ?? currentLessonIndex)
    }

    private func seekBackward() {
        let current = avPlayer.currentTime()
        let target = max(0, current.seconds - 30)
        avPlayer.seek(to: CMTime(seconds: target, preferredTimescale: 600))
        currentLessonIndex = max(1, currentLessonIndex - 1)
    }

    private func observePlayerErrors() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: avPlayer.currentItem,
            queue: .main
        ) { note in
            playerError = (note.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error)?.localizedDescription
        }
    }

    // MARK: - Progress Observer
    private func startProgressObserver() {
        let interval = CMTime(seconds: 2, preferredTimescale: 600)
        timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [self] time in
            guard let duration = avPlayer.currentItem?.duration.seconds,
                  duration.isFinite, duration > 0 else { return }
            let progress = time.seconds / duration
            playerProgress = min(max(progress, 0), 1)
        }
    }
}

// MARK: - TabHeader (unchanged, kept co-located)
struct TabHeader: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(isSelected ? AppTheme.Typography.footnote.weight(.bold) : AppTheme.Typography.footnote.weight(.medium))
                .foregroundColor(isSelected ? AppTheme.Colors.primary : .gray)
            if isSelected {
                Rectangle()
                    .fill(AppTheme.Colors.primary)
                    .frame(height: 2)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
