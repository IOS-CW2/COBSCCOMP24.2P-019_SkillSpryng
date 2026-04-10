import SwiftUI

struct SessionDetailView: View {
    let session: Session
    @Environment(\.dismiss) var dismiss
    @State private var showRating = false
    @State private var showCancel = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                AppHeader(title: "Session Details", backAction: { dismiss() }, actionIcon: "ellipsis", action: { })
                
                // Hero Status Card
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "1D9E75"), Color(hex: "27E246")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        StatusBadge(text: session.status.rawValue, color: .white)
                            .opacity(0.8)
                        
                        Text(session.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("With \(session.instructorName)")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 12) {
                            DetailsInfoLabel(icon: "calendar", text: session.date)
                            Text("|")
                                .foregroundColor(.white.opacity(0.3))
                            DetailsInfoLabel(icon: "clock", text: session.time)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                // Mentor Info
                HStack(spacing: 16) {
                    Image("instructor1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.instructorName)
                            .font(.system(size: 16, weight: .bold))
                        Text(session.instructorRole)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if let match = session.matchPercentage {
                        Text("MATCH \(match)%")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
                
                // Session Notes
                if let notes = session.notes {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "SESSION NOTES")
                        
                        Text("\"\(notes)\"")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .italic()
                            .lineSpacing(6)
                            .padding()
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                
                // Performance Overview
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "PERFORMANCE OVERVIEW")
                    PerformanceStatGrid(
                        duration: session.duration,
                        credits: session.creditsEarned ?? 0,
                        rating: Double(session.rating ?? 0)
                    )
                }
                .padding(.horizontal)
                
                // Recording Card
                if session.recordingAvailable {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "SESSION RECORDING")
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Available for 30 days", systemImage: "clock.arrow.2.circlepath")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: LessonPlayerView(session: session)) {
                                Text("Watch")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.Colors.primary)
                                    .cornerRadius(20)
                            }
                        }
                        .padding()
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                
                // Primary Actions
                VStack(spacing: 12) {
                    if session.status == .completed {
                        Button(action: { showRating = true }) {
                            Text("Rate Session")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.primary)
                                .cornerRadius(16)
                        }
                    }
                    
                    Button(action: { showCancel = true }) {
                        Text(session.status == .upcoming ? "Cancel Session" : "Remove from History")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.05))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showRating) {
            RateSessionSheet(instructor: session.instructorName)
        }
        .sheet(isPresented: $showCancel) {
            CancelSessionSheet(session: session)
        }
    }
}

struct DetailsInfoLabel: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundColor(.white)
    }
}
