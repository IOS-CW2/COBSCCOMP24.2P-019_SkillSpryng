import SwiftUI

struct LessonPlayerView: View {
    let session: Session
    @Environment(\.dismiss) var dismiss
    @State private var currentLessonIndex = 3
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Video Player Area
            ZStack {
                Color.black
                    .overlay(
                        Image("instructor1") // Background thumbnail
                            .resizable()
                            .scaledToFill()
                            .opacity(0.6)
                    )
                
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.down")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.black.opacity(0.3)))
                        }
                        Spacer()
                        Button(action: { }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.black.opacity(0.3)))
                        }
                    }
                    .padding(.top, 40)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Controls Overlay
                    VStack(spacing: 20) {
                        HStack(spacing: 40) {
                            Image(systemName: "gobackward.10")
                                .font(.title2)
                            Button(action: { isPlaying.toggle() }) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 44))
                            }
                            Image(systemName: "goforward.10")
                                .font(.title2)
                        }
                        .foregroundColor(.white)
                        
                        // Progress Slider
                        VStack(spacing: 8) {
                            HStack {
                                Text("04:12")
                                Spacer()
                                Text(session.recordingDuration ?? "00:00")
                            }
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white)
                            
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 4)
                                Capsule()
                                    .fill(AppTheme.Colors.primary)
                                    .frame(width: 120, height: 4) // Mock progress
                                Circle()
                                    .fill(AppTheme.Colors.primary)
                                    .frame(width: 12, height: 12)
                                    .offset(x: 114)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        HStack {
                            Spacer()
                            Image(systemName: "viewfinder")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 24)
                }
            }
            .frame(height: 300)
            .ignoresSafeArea(edges: .top)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lesson \(currentLessonIndex) of \(session.lessonCount ?? 0) — 42% complete")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Text(session.title)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 8) {
                            Image("instructor1")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text(session.instructorName)
                                    .font(.system(size: 10, weight: .bold))
                                Text(session.instructorRole)
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            StatusBadge(text: "Expert Mentor", color: .green)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal)
                    
                    // Tabs
                    HStack(spacing: 24) {
                        TabHeader(title: "Lessons", isSelected: true)
                        TabHeader(title: "Notes", isSelected: false)
                        TabHeader(title: "Resources", isSelected: false)
                    }
                    .padding(.horizontal)
                    
                    // Lesson List
                    VStack(spacing: 0) {
                        LessonPlaylistRow(index: 1, title: "The Digital Greenhouse Concept", duration: "05:24", isCompleted: true)
                        LessonPlaylistRow(index: 2, title: "Understanding Tonal Depth", duration: "08:12", isCompleted: true)
                        LessonPlaylistRow(index: 3, title: "Mastering Organic Layouts", duration: "10:35", isCurrent: true)
                        LessonPlaylistRow(index: 4, title: "Asymmetry & Balance", duration: "12:45")
                        LessonPlaylistRow(index: 5, title: "Dynamic Typography Scales", duration: "09:30")
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
                Button(action: { }) {
                    Label("Previous", systemImage: "arrow.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.Colors.primary.opacity(0.1), lineWidth: 1))
                }
                
                Spacer()
                
                Button(action: { }) {
                    HStack {
                        Text("Next Lesson")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(12)
                }
            }
            .padding(24)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
        }
        .navigationBarHidden(true)
    }
}

struct TabHeader: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? AppTheme.Colors.primary : .gray)
            
            if isSelected {
                Rectangle()
                    .fill(AppTheme.Colors.primary)
                    .frame(height: 2)
            }
        }
    }
}
